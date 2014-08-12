open import Common
module Id.Struct where

record Struct : Set where
  constructor `s
  field
    name : ℕ

`s-inj : ∀ {a b} → `s a ≡ `s b → a ≡ b
`s-inj refl = refl

==Struct : (a b : Struct) → Dec (a ≡ b)
==Struct (`s a) (`s b) with a == b
==Struct (`s a) (`s .a) | yes refl = yes refl
==Struct (`s a) (`s b)  | no neq = no (neq ∘ `s-inj)

EqVar : Eq Struct
EqVar = record { _==_ = ==Struct }

test-A = `s 0
test-B = `s 1
test-C = `s 2
test-D = `s 3
test-E = `s 4
