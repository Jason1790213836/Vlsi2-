📘 VLSI Lab – Synthesis, Timing, and Power Analysis
📌 Overview

This lab focuses on using Synopsys Design Compiler (DC) to perform RTL synthesis, analyze timing constraints, and evaluate power consumption.
We explore how different standard cell libraries (LVT vs HVT) affect:

Timing (setup slack)
Power consumption
Design trade-offs
⚙️ Design Flow

The synthesis flow includes:

Setup Environment
Load library files (.db, .ndm)
Define target library (LVT / HVT)

Read and Elaborate Design

analyze -f verilog TOP.v
elaborate TOP
Apply Constraints
Clock definition
Input/output delays
Driving cell and load

Synthesis

compile_ultra
Analysis
Timing: report_timing
Power: report_power
Constraints: report_constraints
⏱️ Timing Analysis

We analyze setup timing using:

report_timing
Only max paths are considered for setup
Critical path identified using slack histogram
🎯 Constraint Requirement

The clock period is adjusted such that:

0 < setup slack < 0.1 ns

This ensures:

Timing is met (no violation)
Minimal performance margin (efficient design)
⚡ Power Analysis

Power is analyzed using:

report_power
Components:
Internal Power
Switching Power
Leakage Power
🔬 LVT vs HVT Comparison
Property	LVT	HVT
Speed	Fast	Slow
Leakage	High	Low
Clock Period	Small	Large
Power	High	Low
📊 Results

From synthesis reports:

power_lvt = 87 uW
power_hvt = 9 uW

👉 LVT consumes significantly more power due to high leakage current.

🧠 Key Observations
Increasing clock period improves slack but reduces performance
LVT cells help meet tight timing constraints
HVT cells reduce leakage but require slower clock
There is a clear timing vs power trade-off
📁 Output Files
TOP.ddc → Gate-level design (Synopsys format)
TOP_netlist.v → Gate-level Verilog netlist
pw_rpt.txt → Final power results
📝 Final Submission Format
power_lvt=87
power_hvt=9
Integer values only
No units
No spaces after =
🚀 Conclusion

This lab demonstrates how synthesis constraints and library choices impact circuit performance and power.
Understanding these trade-offs is essential for optimizing modern digital designs.
