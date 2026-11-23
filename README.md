# ScientificNotationInteger

A lightweight scientific-notation number type that represents values far beyond the
safe range of native integers, using a **mantissa** and an **exponent**
(`mantissa × 10^exponent`). Useful for incremental/idle games, big counters,
and anywhere numbers grow past `Number.MAX_SAFE_INTEGER`. It supports arbitrarily large/small magnitudes, along with negative numbers.

Two parallel implementations are provided:

| File | Language | Runtime | Style |
|------|----------|---------|-------|
| `ScientificNotationInteger.py` | Python 3 | CPython | Class with explicit methods (`Add`, `IsGreaterThan`, ...) |
| `ScientificNotationInteger.luau` | Luau | Roblox | Metatable object with operator overloads (`+`, `-`, `*`, `/`, `<`, `>`, `==`) |

## How it works

Every value is stored normalized so that `1 <= |mantissa| < 10` (or `mantissa == 0`).
For example, `1,234,567` is stored as `mantissa = 1.234567`, `exponent = 6`.

Because the exponent is tracked separately, this can represent arbitrarily large
(or small) magnitudes without overflowing — limited only by floating-point
precision on the mantissa (~15–17 significant digits).

## Complexity

All operations run in **O(1) time and O(1) space**. Values are fixed-size
(mantissa + exponent), so arithmetic, comparison, and serialization never scale
with the magnitude of the number — unlike bigint approaches whose cost grows with
digit count.

> Caveat: `Normalize()` (used internally by most methods) corrects the mantissa
> with a loop of multiply/divide-by-10 steps, so strictly it is O(k) where `k` is
> the number of digits the mantissa sits outside `[1, 10)`. Because inputs are kept
> normalized, `k` stays tiny in practice, making it effectively constant. For a
> strict guarantee, replace those loops with a single `log10`/`floor` adjustment.


## Abbreviations

`Abbreviate()` formats a number with a named suffix, stepping every three orders
of magnitude:

```text
K   Thousand      M   Million     B   Billion     T   Trillion
Qa  Quadrillion  Qi  Quintillion Sx  Sextillion  Sp  Septillion
O   Octillion    N   Nonillion   Dc  Decillion   ... up to ... Qd
```

The full list runs from `""` (ones) through `Qd` (centillion-range names).

---

## Python usage

```python
n1 = ScientificNotationInteger(5, 5.23456789)   # 5.23456789 * 10^5
n2 = ScientificNotationInteger(7, 8.6)          # 8.6 * 10^7

print(n1.Abbreviate())   # "523.457 K"
print(n2.Abbreviate())   # "86 M"

n1.Add(n2)               # mutates n1 in place
print(n1.toString())     # "8.6523456789 * 10^7"
print(n1.Abbreviate())   # "86.523 M"
```

### API

| Method | Description |
|--------|-------------|
| `getMantissa()` / `getExponent()` | Accessors for the raw fields |
| `toString()` | Full `"m * 10^e"` string form |
| `Abbreviate()` | Human-readable string with suffix (e.g. `1.5 B`) |
| `Normalize()` | Re-normalizes mantissa into `[1, 10)` |
| `Add(num)` / `Subtract(num)` | In-place addition / subtraction |
| `Multiply(num)` / `Divide(num)` | In-place multiplication / division |
| `IsGreaterThan` / `IsLessThan` / `IsEqualTo` | Comparisons |

All arithmetic and comparison methods accept either another
`ScientificNotationInteger` **or** a plain `int`/`float` (auto-converted via
`numberToScientificNotation`). Invalid types print `"Invalid input type."`.

> Note: Python methods mutate the receiver in place and return `None`.

---

## Luau (Roblox) usage

```lua
local SN = require(script.ScientificNotationInteger)

local n1 = SN.new(5, 5.23456789)
local n2 = SN.new(7, 8.6)

print(n1:Abbreviate())        -- "523.457 K"
print(n1 + n2)                -- operator overloads supported
print(n1 * 1000 > n2)         -- comparisons mix with plain numbers
print(n1:Serialize())         -- returns a 12-byte buffer (i32 exp + f64 mantissa)
```

### Features

- **Operator overloads:** `__add`, `__sub`, `__mul`, `__div`, `__eq`, `__lt`, `__gt`, `__tostring`.
- **Mixed operands:** Every operator coerces plain `number`s automatically.
- **`Serialize()`**: Packs the value into a `buffer` (4-byte `i32` exponent +
  8-byte `f64` mantissa) for saving/networking.
- **Typed:** Exports a `ScientificNotation` type definition for strict Luau.

---

## Precision & limitations

- The mantissa is a standard double, so results carry roughly **15–17 significant
  digits**; adding a tiny value to a huge one may lose the small term entirely.
- Division by zero is not guarded — check divisors yourself.
- The Luau `Abbreviate()` will index out of bounds if `exponent // 3` exceeds the
  abbreviation table (≈ exponent ≥ 123); clamp or extend `ABBREVIATIONS` as needed.

## License

MIT — see `LICENSE`.
