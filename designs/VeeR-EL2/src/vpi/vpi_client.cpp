// Copyright 2025 RTLMeter contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

// cocotb-style VPI client: AXI monitor reading valid/ready every cycle and the payload on
// handshakes, event-driven puts on the memory models' stored handshake outputs, and
// architectural state sampling every 1000 cycles. Prints a checksum of the payloads and samples.

#include "vpi_user.h"

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

namespace {

struct Sig {
    vpiHandle h;
    int words;
    PLI_INT32 last = -1;
};

struct Channel {
    const char* bus;
    const char* name;
    std::vector<const char*> payloadNames;
    Sig valid{};
    Sig ready{};
    std::vector<Sig> payload{};
    uint64_t handshakes = 0;
};

std::vector<Channel> s_channels = {
    {"ifu", "ar", {"araddr"}}, {"ifu", "r", {"rdata", "rid"}}, {"lsu", "ar", {"araddr"}},
    {"lsu", "r", {"rdata"}},   {"lsu", "aw", {"awaddr"}},      {"lsu", "w", {"wdata", "wstrb"}},
    {"lsu", "b", {"bresp"}},
};
std::vector<Sig> s_drive;
std::vector<Sig> s_state;
uint64_t s_sum = 1469598103934665603ULL;
uint64_t s_cycles = 0;
uint64_t s_reads = 0;
uint64_t s_puts = 0;
uint64_t s_putErrors = 0;
uint64_t s_putCycles = 0;
uint64_t s_samples = 0;
constexpr uint64_t STATE_PERIOD = 1000;
s_vpi_time s_suppressTime{vpiSuppressTime, 0, 0, 0.0};
s_vpi_value s_clkVal{vpiScalarVal, {nullptr}};

const char* const s_driveNames[] = {"imem.arready", "imem.rvalid", "lmem.arready", "lmem.rvalid",
                                    "lmem.awready", "lmem.wready", "lmem.bvalid"};
const char* const s_csrNames[] = {"mcyclel", "mcycleh",  "minstretl", "minstreth", "mepc",
                                  "mcause",  "mscratch", "mtvec",     "npc_r"};

Sig lookup(const std::string& name) {
    vpiHandle h = vpi_handle_by_name(const_cast<PLI_BYTE8*>(name.c_str()), nullptr);
    if (!h) {
        std::fprintf(stderr, "vpi_client: cannot find %s\n", name.c_str());
        std::exit(1);
    }
    return Sig{h, (vpi_get(vpiSize, h) + 31) / 32};
}

PLI_INT32 readInt(const Sig& s) {
    s_vpi_value v{vpiIntVal, {nullptr}};
    vpi_get_value(s.h, &v);
    ++s_reads;
    return v.value.integer;
}

void readFold(const Sig& s) {
    s_vpi_value v{vpiVectorVal, {nullptr}};
    vpi_get_value(s.h, &v);
    ++s_reads;
    for (int i = 0; i < s.words; ++i) {
        s_sum = (s_sum ^ v.value.vector[i].aval) * 1099511628211ULL;
        s_sum = (s_sum ^ v.value.vector[i].bval) * 1099511628211ULL;
    }
}

PLI_INT32 onClock(p_cb_data cbp) {
    if (cbp->value->value.scalar != vpi1) return 0;
    ++s_cycles;
    for (Channel& c : s_channels) {
        if (!(readInt(c.valid) & readInt(c.ready))) continue;
        ++c.handshakes;
        for (const Sig& s : c.payload) readFold(s);
    }
    // Like a cocotb AXI slave, write a handshake reg only when it changed since the previous
    // edge, and write the value it already holds so simulation results are unchanged.
    bool put = false;
    for (Sig& s : s_drive) {
        s_vpi_value v{vpiIntVal, {nullptr}};
        v.value.integer = readInt(s);
        if (v.value.integer == s.last) continue;
        s.last = v.value.integer;
        vpi_put_value(s.h, &v, nullptr, vpiNoDelay);
        ++s_puts;
        put = true;
        if (vpi_chk_error(nullptr)) ++s_putErrors;
    }
    s_putCycles += put;
    if (s_cycles % STATE_PERIOD == 0) {
        ++s_samples;
        for (const Sig& s : s_state) readFold(s);
    }
    return 0;
}

PLI_INT32 onEnd(p_cb_data) {
    std::printf("vpi_client: cycles=%llu reads=%llu puts=%llu putCycles=%llu putErrors=%llu "
                "samples=%llu\n",
                (unsigned long long)s_cycles, (unsigned long long)s_reads,
                (unsigned long long)s_puts, (unsigned long long)s_putCycles,
                (unsigned long long)s_putErrors, (unsigned long long)s_samples);
    for (const Channel& c : s_channels)
        std::printf("vpi_client: %s %s handshakes=%llu\n", c.bus, c.name,
                    (unsigned long long)c.handshakes);
    std::printf("vpi_client: checksum=%016llx\n", (unsigned long long)s_sum);
    return 0;
}

void registerCb(PLI_INT32 reason, PLI_INT32 (*fn)(p_cb_data), vpiHandle obj) {
    s_cb_data cb{};
    cb.reason = reason;
    cb.cb_rtn = fn;
    cb.obj = obj;
    cb.time = &s_suppressTime;
    cb.value = &s_clkVal;
    vpi_free_object(vpi_register_cb(&cb));
}

PLI_INT32 onStart(p_cb_data) {
    for (Channel& c : s_channels) {
        const std::string prefix = std::string{"tb_top."} + c.bus + "_axi_";
        c.valid = lookup(prefix + c.name + "valid");
        c.ready = lookup(prefix + c.name + "ready");
        for (const char* n : c.payloadNames) c.payload.push_back(lookup(prefix + n));
    }
    for (const char* n : s_driveNames) s_drive.push_back(lookup(std::string{"tb_top."} + n));
    const std::string dec = "tb_top.rvtop_wrapper.rvtop.veer.dec.";
    for (int j = 1; j < 32; ++j)
        s_state.push_back(lookup(dec + "arf.gpr[" + std::to_string(j) + "].gprff.dout"));
    for (const char* n : s_csrNames) s_state.push_back(lookup(dec + "tlu." + n));
    registerCb(cbValueChange, onClock, lookup("tb_top.core_clk").h);
    registerCb(cbEndOfSimulation, onEnd, nullptr);
    return 0;
}

void startup() {
    s_cb_data cb{};
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = onStart;
    vpi_free_object(vpi_register_cb(&cb));
}

}  // namespace

void (*vlog_startup_routines[])() = {startup, nullptr};
