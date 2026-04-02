# 📘 VLSI Lab – Synthesis, Timing, and Power Analysis

## 📌 Overview

This lab focuses on using **Synopsys Design Compiler (DC)** to perform RTL synthesis, analyze timing constraints, and evaluate power consumption. 

We explore how different standard cell libraries (**LVT** vs **HVT**) affect:
- **Timing** (setup slack)
- **Power consumption**
- **Design trade-offs**

---

## ⚙️ Design Flow

The synthesis flow includes the following key steps:

### 1. Setup Environment
- Load library files (`.db`, `.ndm`)
- Define target library (LVT / HVT)

### 2. Read and Elaborate Design
```tcl
analyze -f verilog TOP.v
elaborate TOP
3. Apply ConstraintsDefine clock periodSet input/output delaySet driving cell and load4. SynthesisTclcompile_ultra
5. AnalysisTiming analysis: report_timingPower analysis: report_powerConstraint checking: report_constraints⏱️ Timing AnalysisSetup timing is analyzed using the report_timing command.Key points:Only max paths are considered for setup timing.Critical paths are identified using the slack histogram.The worst slack determines whether the timing design is successful.🎯 Constraint RequirementThe clock period is adjusted such that:0 < setup slack < 0.1 nsThis ensures:Timing is met (no violation).Minimal performance margin (efficient design without over-constraining).⚡ Power AnalysisPower is analyzed using the report_power command, focusing on three main components:Internal PowerSwitching PowerLeakage Power🔬 LVT vs HVT ComparisonPropertyLVT (Low Threshold)HVT (High Threshold)SpeedFastSlowLeakageHighLowClock PeriodSmall (High Freq)Large (Low Freq)Power ConsumptionHighLow📊 Results & ObservationsResults ExampleFrom synthesis reports:power_lvt = 87 uWpower_hvt = 9 uW🧠 Key ObservationsTrade-off: Increasing the clock period improves slack but reduces performance.Library Choice: LVT cells help meet tight timing constraints at the cost of power. HVT cells are ideal for low-power designs that don't require maximum speed.Leakage: LVT consumes significantly more power primarily due to higher leakage current.📁 Output FilesTOP.ddc: Gate-level design (Synopsys format).TOP_netlist.v: Gate-level Verilog netlist.pw_rpt.txt: Final power results for submission.📝 Final Submission Format (pw_rpt.txt)Requirements: Integer values only (truncate), no units, no spaces.Plaintextpower_lvt=87
power_hvt=9
🚀 ConclusionThis lab demonstrates how synthesis constraints and library choices impact circuit performance and power consumption. Understanding the Timing vs. Power trade-off is essential for modern digital IC design.
