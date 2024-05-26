import sys
from clingo.symbol import Function, Number
from clingo.application import Application, clingo_main
class IncConfig:
    def init(self):
        self.imin, self.imax, self.istop = 1, None, "SAT"
# [...]

class IncExampleApp(Application):
    program_name = "inc-example"
    version = "1.0"
    def init(self):
        self._conf = IncConfig()
    def register_options(self, options):
        group = "Inc - Example Options"
        options.add(
            group, "imin",
            f"Minimum number of steps [{self._conf.imin}] ",
            parse_int(self._conf, "imin", min_val=0) ,
            argument="<n>")
        options.add(
            group, " imax ",
            f"Maximum number of steps [{ self._conf.imax }] ",
            parse_int(self._conf, "imax", min_val=0 , optional=True),
            argument="<n>")
        options.add(
            group, "istop",
            f"Stop criterion [{ self._conf.istop}] ",
            parse_stop(self._conf, "istop"))

    def main(self, ctl, files ):
        if not files: files = ["-"]
        for f in files: ctl.load(f)
        ctl.add("check", ["t"], "#external query ( t ).")

        conf = self._conf
        imin, imax, istop = conf.imin, conf.imax, conf.istop

        step, ret=0, None
        while((imax is None or step < imax) and
                (step == 0 or step < imin or (
                    (istop == "SAT" and not ret.satisfiable) or
                    (istop == "UNSAT" and not ret.unsatisfiable) or
                    (istop == "UNKNOWN" and not ret.unknown)))):
            parts = []
            parts.append(("check", [Number(step)]))
            if step > 0:
                query = Function ("query", [Number(step - 1)])
                ctl.release_external(query)
                parts.append(("step", [Number(step)]))
            else :
                parts.append(("base", []))
            ctl.ground(parts)
            query = Function("query", [Number(step)])
            ctl.assign_external(query, True)
            ret, step = ctl.solve(), step+1
clingo_main(IncExampleApp(), sys.argv[1:])
