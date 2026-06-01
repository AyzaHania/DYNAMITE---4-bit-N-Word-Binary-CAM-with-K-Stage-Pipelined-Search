# DYNAMITE
### 4-bit N-Word Binary CAM with K-Stage Pipelined Search

> **University of Cincinnati — Intro to VLSI Design**
> **Group 10 | December 2025**

---

## What is This?

**DYNAMITE** is a fully custom VLSI chip implementing a **Binary Content-Addressable Memory (CAM)**.

Unlike regular memory where you look up data *by address*, a CAM works in reverse — you give it a **data value** and it tells you **where** that value is stored, by searching all 512 memory locations **simultaneously in parallel hardware**.

---

## Key Specs

| Parameter | Value |
|---|---|
| Chip Name | DYNAMITE |
| Word Width | 4 bits |
| Number of Words (N) | 512 |
| Pipeline Stages (K) | 5 (supports 4, 5, 6) |
| Technology | GSCLIB045 — 45 nm CMOS |
| Synthesis Frequency | **840.3 MHz** |
| Post-Route Frequency | **86.96 MHz** |
| Total Cell Count | 16,664 |
| Cell Area | 30,142.854 µm² |
| Bounding Box | 250 µm × 250 µm |
| Chip Utilisation | ~53% |
| DRC Violations | **Zero** |
| Synthesis Tool | Cadence Genus 21.19 |
| P&R Tool | Cadence Innovus 21.19 |
| Simulation Tool | Cadence NCVerilog / SimVision |

---

## Architecture

```
search_word[3:0]
      │
  ┌───▼───┐   ┌───────┐   ┌───────┐   ┌───────┐   ┌───────┐
  │  s0   │──▶│  s1   │──▶│  s2   │──▶│  s3   │──▶│  s4   │   ← 5-stage pipeline
  └───────┘   └───────┘   └───────┘   └───────┘   └───┬───┘
                                                        │
              ┌─────────────────────────────────────────▼──────────────┐
              │        512 × 4-bit Parallel Comparators                  │
              │        match_vector[j] = (s4 == mem[j])  for j=0..511   │
              └──────────────────────────┬──────────────────────────────┘
                                         │
                             ┌───────────▼───────────┐
                             │    Priority Encoder     │
                             │  (lowest index wins)    │
                             └───────────┬─────────────┘
                                         │
                              ┌──────────▼──────────┐
                              │   Output Registers   │
                              │   match_found        │
                              │   match_index[8:0]   │
                              └─────────────────────┘
```

Search results appear exactly **5 clock cycles** after the input is applied.

---

## Pin Description

| Pin | Direction | Width | Description |
|---|---|---|---|
| `clk` | Input | 1 | System clock |
| `reset` | Input | 1 | Async active-high reset — initialises `mem[i] = i[3:0]` |
| `test_mode` | Input | 1 | Forces `match_found=1`, `match_index=0` for DFT |
| `scan_en` | Input | 1 | Scan chain enable |
| `scan_in` | Input | 1 | Scan chain serial input |
| `scan_out` | Output | 1 | Scan chain serial output |
| `write_enable` | Input | 1 | Memory write enable (active high) |
| `write_addr` | Input | 9 | Write address (0–511) |
| `write_data` | Input | 4 | 4-bit data to write |
| `search_word` | Input | 4 | 4-bit value to search for |
| `match_found` | Output | 1 | High if any match exists |
| `match_index` | Output | 9 | Address of the first (lowest) matching word |

---

## Repository Structure

```
DYNAMITE-CAM/
│
├── rtl/
│   └── cam.v                      # Synthesisable RTL — parameterised N & K
│
├── tb/
│   ├── cam_tb.v                   # RTL testbench (pre-synthesis)
│   ├── cam_tb_postsyn.v           # Post-synthesis testbench with SDF
│   └── cam_tb_postroute.v         # Post-route testbench with RC SDF
│
├── synthesis/
│   └── genus_synth.tcl            # Cadence Genus synthesis script
│
├── innovus/
│   ├── innovus_pnr.tcl            # Cadence Innovus place-and-route script
│   └── Constraints.sdc            # SDC timing constraints (11.5 ns clock)
│
├── docs/
│   ├── first_report.pdf           # Phase 1–3: RTL & simulation
│   ├── second_progress_report.pdf # Phase 4: Logic synthesis
│   └── final_report.pdf           # Final: P&R, DRC, layout
│
├── scripts/
│   └── run_sim.sh                 # Run any simulation in one command
│
├── .gitignore
└── README.md
```

---

## How to Run

### RTL Simulation
```bash
./scripts/run_sim.sh rtl
# or manually:
ncverilog +access+r rtl/cam.v tb/cam_tb.v -l rtl_sim.log
```

### Logic Synthesis (Genus)
```bash
cd synthesis
genus -f genus_synth.tcl
# Outputs: cam_map.v, cam_map.sdf, timing/area reports
```

### Post-Synthesis Simulation
```bash
./scripts/run_sim.sh postsyn
```

### Place and Route (Innovus)
```bash
cd innovus
innovus -files innovus_pnr.tcl
# Outputs: camwithRC.sdf, routed netlist, DRC report
```

### Post-Route Simulation
```bash
./scripts/run_sim.sh postroute
```

---

## Results

### Logic Synthesis — Genus

| Metric | Value |
|---|---|
| Cell Count | 16,664 |
| Synthesis Area | 30,211.596 µm² |
| Clock Period | 1.190 ns |
| Max Frequency | **840.3 MHz** |
| Worst Slack | 1 ps |
| Critical Path | Pipeline reg → Comparators → Priority Encoder → Output reg |
| Critical Path Delay | 1,189 ps |

**Area Breakdown:**

| Block | Estimated Area | Share |
|---|---|---|
| Memory array (512 × 4 FFs) | ~20,000 µm² | 66% |
| 512 Parallel comparators | ~6,000 µm² | 20% |
| Priority encoder | ~3,500 µm² | 12% |
| Pipeline registers + control | ~725 µm² | 2% |

### Place & Route — Innovus

| Metric | Value |
|---|---|
| Clock Period | 11.5 ns (86.96 MHz) |
| Setup WNS (post-CTS) | 8.450 ns |
| Hold WNS (post-CTS) | 0.002 ns |
| TNS | 0.000 ns |
| DRC Violations | **Zero** |
| Design Density | 53% |
| Routing Overflow | 0.00% H / 0.00% V |

> **Note on clock:** Genus synthesised at 1.747 ns (572 MHz). After physical implementation, wire delays and routing parasitics caused negative slack (WNS ≈ −0.88 ns). The clock was relaxed to **11.5 ns** to achieve full timing closure — a standard practice in VLSI design flows.

---

## Test Strategy

| Test Case | What It Verifies |
|---|---|
| Reset | Memory initialised; all outputs cleared |
| Write | Correct data stored at specified address |
| Search — single match | Correct index returned after K=5 cycles |
| Search — duplicate values | **Lowest** matching index returned (priority encoding) |
| Search — no match | `match_found = 0` |
| Back-to-back searches | One result per cycle (full pipeline throughput) |
| Test mode | `match_found=1`, `match_index=0` regardless of input |
| Scan chain | Serial shift through all pipeline flip-flops |
| Post-synthesis SDF | Functional correctness with real gate delays |
| Post-route SDF | Functional correctness with RC parasitics |

---

## Design Evolution

| Phase | N (words) | K (stages) | Key Change |
|---|---|---|---|
| First Report | 16–32 (estimate) | 4 | Initial RTL; used wire assignment (not real FFs) |
| Second Report | **512** | 5 | Fixed synthesis bug; added real register array + write interface |
| Final Report | **512** | 5 | Full P&R; DRC clean; scan chain added |

The key breakthrough was replacing `wire [3:0] mem_word = j[3:0]` — which Genus optimised down to only 16 comparators — with a genuine `reg [3:0] mem [0:N-1]` array, making area scale correctly with N.
