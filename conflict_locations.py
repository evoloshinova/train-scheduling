import clingo

# Load the original plan and conflict detection logic
program = """
% construct the conflict atoms for locations that are passed by more than one agent
conflict_location(agent(A1), agent(A2), (Y, X)) :- 
    orig(agent(A1), (Y,X), FirstAgentTime, _), 
    orig(agent(A2), (Y,X), SecondAgentTime, _), 
    FirstAgentTime < SecondAgentTime, 
    A1 != A2.

#show conflict_location/3.
"""

ctl = clingo.Control()
ctl.load("original_plan.lp")
ctl.add("base", [], program)
ctl.ground([("base", [])])

# Capture the conflict locations
conflicts = []

def on_model(model):
    global conflicts
    conflicts = [str(atom) for atom in model.symbols(shown=True) if atom.name == "conflict_location"]

ctl.solve(on_model=on_model)

# Write the conflicts to a file
with open("conflict_locations.lp", "w") as f:
    for conflict in conflicts:
        f.write(f"{conflict}.\n")

print("Conflict locations written to conflict_locations.lp")
