# 📘 VLSI Lab – Synthesis, Timing, and Power Analysis

## 📌 Overview

This lab focuses on using Synopsys Design Compiler (DC) to perform RTL synthesis, analyze timing constraints, and evaluate power consumption.

We explore how different standard cell libraries (LVT vs HVT) affect:

- Timing (setup slack)
- Power consumption
- Design trade-offs

---

## ⚙️ Design Flow

The synthesis flow includes the following steps:

### 1. Setup Environment
- Load library files (.db, .ndm)
- Define target library (LVT / HVT)

### 2. Read and Elaborate Design

```tcl
    analyze -f verilog TOP.v
    elaborate TOP
```

### 3. Apply Constraints
- Define clock period
- Set input/output delay
- Set driving cell and load

### 4. Synthesis

```tcl
    compile_ultra
```

### 5.Analysis
- Timing analysis: report_timing
- Power analysis: report_power
- Constraint checking: report_constraints
  
## ⏱️ Timing Analysis
Setup timing is analyzed using:
```tcl
    report_timing
```
Key points:
- Only max paths are considered for setup timing
- Critical paths are identified using slack histogram
- The worst slack determines whether timing is met

## 🎯 Constraint Requirement
The clock period is adjusted such that:
```tcl
    0 < setup slack < 0.1 ns
```
This ensures:
- Timing is met (no violation)
- Minimal performance margin (efficient design)
## ⚡ Power Analysis
Power is analyzed using:
```tcl
    report_power
```
### Power Components
- Internal Power
- Switching Power
- Leakage Power

## 🔬 LVT vs HVT Comparison

| Property | LVT | HVT |
| :--- | :--- | :--- |
| Speed | Fast | Slow |
| Leakage | High | Low |
| Clock Period | Small | Large |
| Power Consumption | High | Low |

---

## 📊 Results

From synthesis reports:

```text
power_lvt = 87 uW
power_hvt = 9 uW

```
👉 **LVT consumes significantly more power due to higher leakage current.**

### 🧠 Key Observations
- Increasing clock period improves slack but reduces performance.
- LVT cells help meet tight timing constraints.
- HVT cells reduce leakage but require slower clock.
- There is a clear timing vs power trade-off.
