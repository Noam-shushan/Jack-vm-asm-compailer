
def push_constant(const: int):
    return [f'@{const}', 'D=A', '@0', 'A=M', 'M=D', '@0', 'M=M+1']


def stack_opertion(operator: str):
    return ['@0', 'A=M-1', 'D=M', '@0', 'A=M-1', 'M=M'+operator+'D', '@0', 'M=M-1']


def map_line(line):
    if line.startswith('push constant'):
        constant = line.split(' ')[-1]
        return push_constant(constant)
    elif line.startswith('add'):
        return stack_opertion('+')
    elif line.startswith('sub'):
        return stack_opertion('-')


def convert_vm_to_hack(path, vm_file_name):

    with open(path + vm_file_name, 'r') as vm_f:
        only_code_lines = filter(lambda line: not line.startswith(
            r'//') and not line.isspace(), vm_f.readlines())
        vm_lines = map(lambda line: line.strip(), only_code_lines)

        hack_code = []
        for line in vm_lines:
            hack_code += map_line(line)

        asm_file_name = vm_file_name.replace('.vm', '.asm')
        with open(path + asm_file_name, 'w') as hack_f:
            hack_f.write('\n'.join(hack_code))


if __name__ == '__main__':
    path = 'C:\\Users\\Asuspcc\\TclWorks\\projects\\07\\StackArithmetic\\SimpleAdd\\'
    vm_file_name = 'SimpleAdd.vm'
    convert_vm_to_hack(path, vm_file_name)
