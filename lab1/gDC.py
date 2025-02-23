def gdc(num1: int, num2: int) -> int|None:
    if num1!=num2:
        if num1>num2:
            return gdc((num1-num2), num2)
        else:
            return gdc(num2, num1)
    else:
        return num1

if __name__ == '__main__':
    print(gdc(1992,996))