"""Unicorn instruction budgets are not function-return evidence."""
def run_until_return(uc, entry, sentinel, max_insns, pc_register, label):
    if max_insns <= 0:
        raise ValueError('A positive instruction budget is required')
    uc.emu_start(entry, sentinel, count=max_insns)
    pc = uc.reg_read(pc_register)
    if pc != sentinel:
        raise RuntimeError(f'{label} did not return: instruction budget/early stop at {pc:#x}; expected sentinel {sentinel:#x}. No next phase executed')
