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
- Load library files (`.db`, `.ndm`)
- Define target library (LVT / HVT)

### 2. Read and Elaborate Design

```tcl
analyze -f verilog TOP.v
elaborate TOP

### 3. Apply Constraints
Define clock period
Set input/output delay
Set driving cell and load
