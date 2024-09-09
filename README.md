# Train Scheduling for the Flatland Problem using Answer Set Programming

This repository contains the code and resources for solving the **Flatland Train Scheduling Problem** using **Answer Set Programming (ASP)** with **clingo** and **Python**. The solution is split into two phases: 
1. **Incremental solving** to compute an optimal train schedule.
2. **Dynamic handling of malfunctions** using two different approaches:
   - Immediate Delay Approach
   - Shifted Delay Approach

## Overview

The Flatland problem involves scheduling multiple agents (trains) on a grid environment with various track configurations, avoiding collisions and ensuring that each agent reaches its destination efficiently. The environment is dynamic, and agents can face malfunctions during execution, which require real-time re-planning. 

This project integrates **ASP** and **Python** to incrementally solve this scheduling problem using **clingo**. The code also includes mechanisms to handle malfunctions in real-time using **Temporal Plan Graph (TPG)** approaches.

## Project Structure

- `encoding_orig.lp`: ASP encoding for generating the initial optimal train schedule.
- `encoding_immediate_delay.lp`: ASP encoding for handling malfunctions with the Immediate Delay Approach.
- `encoding_shifted_delay.lp`: ASP encoding for handling malfunctions with the Shifted Delay Approach.
- `inc_orig.py`: Python script that performs incremental solving for the initial train schedule.
- `inc_delay.py`: Python script that handles dynamic malfunctions using either the Immediate or Shifted Delay approaches.
- `instances/`: Directory containing Flatland environment instances.
- `train_scheduling.ipynb`: Jupyter notebook to run the complete solution, including incremental solving and malfunction handling.

## Prerequisites

To run this project, you need to install the following dependencies:

- **Python 3.9+**
- **clingo** (ASP solver)
- **numpy** (for random delays in malfunction handling)
- **Jupyter Notebook** (for the provided workflow)

You can install the dependencies using the appropriate Python package installer.

## Running the Project

The project is divided into two main phases:

### 1. Generating the Optimal Plan

The first step is to compute an optimal schedule for the trains using incremental solving with **clingo**. This step generates a file called `original_plan.lp` that contains the agent-location table for each time step.
Run the following command:

```bash
python inc_orig.py encoding_orig.lp instances/flatland_environment_instance.lp --imax 100
```

- `encoding_orig.lp`: ASP encoding for the original problem.
- `instances/flatland_environment_instance.lp`: Environment instance file specifying the Flatland grid.
- Set the maximum number of time steps to a desired limit.

### 2. Handling Malfunctions in Real-Time

After generating the initial plan, you can simulate malfunctions and handle them dynamically using either the **Immediate Delay** or **Shifted Delay** approaches.

#### Immediate Delay Approach

In this approach, the second agent (A2) waits immediately at a conflict location when another agent (A1) is delayed. Run this Python command to handle the malfunction using the Immediate Delay approach.

```bash
python inc_delay.py encoding_immediate_delay.lp instances/flatland_environment_instance.lp --imax 100 --delay_rate 0.2 --min_duration 2 --max_duration 5
```

- `encoding_immediate_delay.lp`: ASP encoding for handling malfunctions with Immediate Delay.
- Set the malfunction probability and define the range for malfunction durations.

#### Shifted Delay Approach

In this approach, agent A2 waits at the position preceding the conflict location until its cumulative delay matches agent A1’s. Run this Python command to handle the malfunction using the Shifted Delay approach.

```bash
python inc_delay.py encoding_shifted_delay.lp instances/flatland_environment_instance.lp --imax 100 --delay_rate 0.2 --min_duration 2 --max_duration 5
```

- `encoding_shifted_delay.lp`: ASP encoding for handling malfunctions with Shifted Delay.
  
### 3. Using the Jupyter Notebook

You can also run the project using the provided Jupyter notebook, `train_scheduling.ipynb`. This notebook includes cells to:
1. Generate the optimal plan.
2. Simulate malfunctions with the Immediate Delay Approach.
3. Simulate malfunctions with the Shifted Delay Approach.

To run the notebook, use

```bash
jupyter notebook train_scheduling.ipynb
```

## Explanation of the Methods

### Incremental Solving

Incremental solving allows us to generate an optimal schedule for the trains with a minimal number of time steps. The ASP program is incrementally grounded and solved for increasingly larger time horizons until a solution is found. The `inc_orig.py` script manages this process.

### Malfunction Handling

Malfunctions are handled using two main approaches:
1. **Immediate Delay Approach**: Agents stop immediately at conflict locations when another agent is delayed.
2. **Shifted Delay Approach**: Agents stop at positions before the conflict locations and proceed only when their cumulative delay matches the original plan.

Both approaches prevent collisions and allow trains to continue safely to their destinations.

## References

- [Flatland: Multi-Agent Railway Control](https://arxiv.org/abs/2003.03887)
- [How to build your own ASP-based system?!](https://www.cs.uni-potsdam.de/wv/publications/DBLP_journals/corr/abs-2008-06692.pdf)
- [Conflict-Based Search for Optimal Multi-Agent Path Finding](https://ojs.aaai.org/index.php/ICAPS/article/view/13796)
