def numberToScientificNotation(num):
    if (type(num) is not int) and (type(num) is not float):
        print("Invalid input type.")
        return
    
    result = ScientificNotationInteger()
    sign = 1

    if num < 0:
        num *= -1
        sign = -1
    elif num == 0:
        result.mantissa = 0.0
        result.exponent = 0
        return result

    while num >= 10:
        num /= 10
        result.exponent += 1

    while num < 1:
        num *= 10
        result.exponent -= 1
            
    result.mantissa = num * sign
    return result

class ScientificNotationInteger:
    DISPLAYED_PRECISION = 3 # Max number of decimals to be displayed when abbreviated        
    ABBREVIATIONS = ["", "K", "M", "B", "T", "Qa", "Qi","Sx", "Sp","O", "N", "Dc", "Udc", "Ddc", "Tdc", "Qadc", "Qidc", "Sxdc", "Spdc", "Ocdc", "Nmdc", "Vg", "Uvg", "Dvg", "Tvg", "Qavg", "Qivg", "Sxvg", "Spvg", "Ovg", "Nvg", "Tg", "Utg", "Dtg", "Ttg", "Qatg", "Qitg", "Sxtg", "Sptg", "Octg", "Notg", "Qd"]       

    def __init__(self, exponent = 0, mantissa = 0.0):
        self.exponent: int = exponent
        self.mantissa: float = mantissa
        self.Normalize()

        
    def getMantissa(self) -> float:
        return self.mantissa

    def getExponent(self) -> int:
        return self.exponent

    def toString(self) -> str:
        if self.mantissa == 0:
            return "0.0"
        elif self.exponent == 0:
            return str(self.mantissa)

        mantissaString = str(self.mantissa)
        decimalPointIndex = mantissaString.index(".")
        string = mantissaString[:decimalPointIndex] + mantissaString[decimalPointIndex + 1:]

        if self.exponent >= 0:
            if self.exponent >= len(mantissaString):
                string += "0" * (self.exponent - len(mantissaString))
            else:
                string = string[:self.exponent] + "." + string[self.exponent:]
        else:
            string = ("0" * -self.exponent) + "." + string            
        
        return f"{string} * 10^{self.exponent}"
    
    def Abbreviate(self) -> str:
        self.Normalize()
        num = self.mantissa * (10 ** (self.exponent % 3))
        print(num)
        if self.exponent >= 0:
            return f"{round(num, self.DISPLAYED_PRECISION)} {self.ABBREVIATIONS[self.exponent // 3]}"       
        else:
            return f"{round(self.mantissa, self.DISPLAYED_PRECISION)} * 10^{self.exponent}"
       
    def IsGreaterThan(self, num) -> bool:
        if (type(num) is int) or (type(num) is float):
            num = numberToScientificNotation(num)
        elif type(num) is not ScientificNotationInteger:
            print("Invalid input type.")
            return False

        if self.exponent > num.exponent:
            return True
        elif self.exponent < num.exponent:
            return False

        return self.mantissa > num.mantissa
        

    def IsLessThan(self, num) -> bool:
        if (type(num) is int) or (type(num) is float):
            num = numberToScientificNotation(num)
        elif type(num) is not ScientificNotationInteger:
            print("Invalid input type.")
            return False

        if self.exponent > num.exponent:
            return False
        elif self.exponent < num.exponent:
            return True

        return self.mantissa < num.mantissa

    def IsEqualTo(self, num) -> bool:
        if (type(num) is int) or (type(num) is float):
            num = numberToScientificNotation(num)
        elif type(num) is not ScientificNotationInteger:
            print("Invalid input type.")
            return False
        
        return self.mantissa == num.mantissa and self.exponent == num.exponent

    def Normalize(self):
        sign = 1

        if self.mantissa == 0:
            self.exponent = 0
        elif self.mantissa < 0:
            self.mantissa *= -1
            sign = -1
        
        while self.mantissa >= 10:
            self.mantissa /= 10
            self.exponent += 1
        
        while self.mantissa < 1:
            self.mantissa *= 10
            self.exponent -= 1

        self.mantissa *= sign
    
    def Add(self, num):
        if (type(num) is int) or (type(num) is float):
            num = numberToScientificNotation(num)
        elif type(num) is not ScientificNotationInteger:
            print("Invalid input type.")
            return
                
        if self.exponent > num.exponent:
            adjustedMantissa = num.mantissa / (10 ** (self.exponent - num.exponent))
            self.mantissa = self.mantissa + adjustedMantissa
        elif self.exponent < num.exponent:
            adjustedMantissa = self.mantissa / (10 ** (num.exponent - self.exponent))
            self.mantissa = num.mantissa + adjustedMantissa
        else:
            self.mantissa = self.mantissa + num.mantissa

        self.exponent = max(self.exponent, num.exponent)
        self.Normalize()
        return

    def Subtract(self, num):
        if (type(num) is int) or (type(num) is float):
            num = numberToScientificNotation(num)
        elif type(num) is not ScientificNotationInteger:
            print("Invalid input type.")
            return

        sign = 1

        if self.exponent > num.exponent:
            adjustedMantissa = num.mantissa / (10 ** (self.exponent - num.exponent))
            self.mantissa = self.mantissa - adjustedMantissa
        elif self.exponent < num.exponent:
            adjustedMantissa = self.mantissa / (10 ** (num.exponent - self.exponent))
            self.mantissa = num.mantissa - adjustedMantissa
            sign = -1
        elif self.IsGreaterThan(num):
            self.mantissa = self.mantissa - num.mantissa
        elif self.IsLessThan(num):
            sign = -1
            self.mantissa = num.mantissa - self.mantissa
        else:
            self.mantissa = 0.0
    

        self.exponent = max(self.exponent, num.exponent)
        self.Normalize()
        self.mantissa *= sign
        return

    def Multiply(self, num):
        if (type(num) is int) or (type(num) is float):
            num = numberToScientificNotation(num)
        elif type(num) is not ScientificNotationInteger:
            print("Invalid input type.")
            return

        self.mantissa = self.mantissa * num.mantissa
        self.exponent = self.exponent + num.exponent
        
        self.Normalize()    
        return

    def Divide(self, num):
        if (type(num) is int) or (type(num) is float):
            num = numberToScientificNotation(num)
        elif type(num) is not ScientificNotationInteger:
            print("Invalid input type.")
            return

        self.mantissa = self.mantissa / num.mantissa
        self.exponent = self.exponent - num.exponent

        self.Normalize()
        return
