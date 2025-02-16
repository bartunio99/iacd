def gdc(num1: int, num2: int) -> int|None:
    if num1 == num2:
        return num1

    elif num2>num1:   #number swap
        num3 = num2
        num2 = num1
        num1 = num3

    newNum :int = num1-num2
    return gdc(num2, newNum)

if __name__ == '__main__':
    gdc(1,2)