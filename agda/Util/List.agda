open import Util.Nat
open import Util.Equality
open import Util.Decidable
open import Util.Product
open import Util.Function
open import Util.Level
open import Util.Empty
module Util.List where
  infixr 5 _∷_
  data List {a} (A : Set a) : Set a where
    []  : List A
    _∷_ : A → List A → List A

  infix 4 [_
  [_ : {A : Set} → List A → List A
  [ as = as

  infixr 5 _,,_
  _,,_ : {A : Set} → A → List A → List A
  a ,, as = a ∷ as

  infixr 5 _]
  _] : {A : Set} → A → List A
  a ] = a ∷ []

  length : ∀ {a} {A : Set a} → List A → ℕ
  length [] = 0
  length (x ∷ xs) = plus 1 $ length xs

  _++_ : ∀ {a} {A : Set a} → List A → List A → List A
  [] ++ ys = ys
  (x ∷ xs) ++ ys = x ∷ xs ++ ys

  map : {A B : Set} → (A → B) → List A → List B
  map f [] = []
  map f (x ∷ xs) = f x ∷ map f xs

  zip : {A B : Set} → List A → List B → List (A × B)
  zip [] ys = []
  zip (x ∷ xs) [] = []
  zip (x ∷ xs) (y ∷ ys) = x , y ∷ zip xs ys

  data Map {A B : Set} (f : A → B) : List A → List B → Set where
    Z : Map f [] []
    S : ∀ {x xs ys} → Map f xs ys → Map f (x ∷ xs) (f x ∷ ys)

  foldr : ∀ {a b} {A : Set a} {B : Set b} → (A → B → B) → B → List A → B
  foldr f z [] = z
  foldr f z (x ∷ xs) = f x (foldr f z xs)

  sum = foldr plus 0

  flatten : ∀ {a} {A : Set a} → List (List A) → List A
  flatten = foldr _++_ []

  data All {a b} {A : Set a} (P : A → Set b) : List A → Set (a ⊔ b) where
    []  : All P []
    _∷_ : ∀ {x xs} → P x → All P xs → All P (x ∷ xs)

  all? : ∀ {a b} {A : Set a} {P : A → Set b} (p? : Decidable P) → Decidable (All P)
  all? p? [] = yes []
  all? p? (x ∷ xs) with p? x | all? p? xs
  all? p? (x ∷ xs) | yes px | yes pxs = yes (px ∷ pxs)
  all? p? (x ∷ xs) | yes px | no ¬pxs = no (λ {(Hx ∷ Hxs) → ¬pxs Hxs})
  all? p? (x ∷ xs) | no ¬px | pxs = no (λ {(Hx ∷ Hxs) → ¬px Hx})

  mapAll : ∀ {a} {A : Set a} {xs} {P Q : A → Set} (f : ∀ {x} → P x → Q x) → All P xs → All Q xs
  mapAll f [] = []
  mapAll f (x ∷ xs) = f x ∷ mapAll f xs

  data Any {a b} {A : Set a} (P : A → Set b) : List A → Set (a ⊔ b) where
    Z : ∀ {x xs} → P x → Any P (x ∷ xs)
    S : ∀ {x xs} → Any P xs → Any P (x ∷ xs)

  any? : ∀ {a b} {A : Set a} {P : A → Set b} (p? : Decidable P) → Decidable (Any P)
  any? p? [] = no (λ ())
  any? p? (x ∷ xs) with p? x
  any? p? (x ∷ xs) | yes px = yes (Z px)
  any? p? (x ∷ xs) | no ¬px with any? p? xs
  any? p? (x ∷ xs) | no ¬px | yes rec = yes (S rec)
  any? p? (x ∷ xs) | no ¬px | no ¬rec = no (λ {(Z px) → ¬px px ; (S px) → ¬rec px})

  extract : ∀ {a} {A : Set a} {xs} {P : A → Set} → Any P xs → A
  extract (Z {x} pf) = x
  extract (S pf) = extract pf

  infix 3 _∈_
  _∈_ : ∀ {a} {A : Set a} (x : A) → List A → Set a
  x ∈ xs = Any (_≡_ x) xs

  _∈?_ : ∀ {a} {A : Set a} {{EqA : Eq A}} (x : A) (xs : List A) → Dec (x ∈ xs)
  x ∈? [] = no (λ ())
  x ∈? (y ∷ xs) with x == y | x ∈? xs
  .y ∈? (y ∷ xs) | yes refl | there = yes (Z refl)
  x ∈? (y ∷ xs) | no ¬here | yes there = yes (S there)
  x ∈? (y ∷ xs) | no ¬here | no ¬there = no (λ { (Z h) → ¬here h ; (S h) → ¬there h })

  infix 3 _⊆_
  _⊆_ : ∀ {a} {A : Set a} (xs ys : List A) → Set a
  xs ⊆ ys = All (λ x → x ∈ ys) xs

  unq-cons : {A : Set} {{EqA : Eq A}} → A → List A → List A
  unq-cons x xs with x ∈? xs
  unq-cons x xs | yes _ = xs
  unq-cons x xs | no  _ = x ∷ xs

  _∪_ : {A : Set} {{EqA : Eq A}} → List A → List A → List A
  [] ∪ ys = ys
  (x ∷ xs) ∪ ys = unq-cons x (xs ∪ ys)

  data NoDup {a} {A : Set a} : List A → Set a where
    nd[] : NoDup []
    _nd∷_ : ∀ {x xs} → ¬ (x ∈ xs) → NoDup xs → NoDup (x ∷ xs)

  nodup? : ∀ {a} {A : Set a} {{EqA : Eq A}} → (xs : List A) → Dec (NoDup xs)
  nodup? [] = yes nd[]
  nodup? (x ∷ xs) with x ∈? xs
  ... | yes pres = no (λ { (¬pres nd∷ H) → ¬pres pres })
  ... | no ¬pres with nodup? xs
  ... | yes ih = yes (¬pres nd∷ ih)
  ... | no ¬ih = no (λ { (¬pres nd∷ H) → ¬ih H })

  data GoesTo {A B : Set} (k : A) : B → List (A × B) → Set where
    Z : ∀ {v xs} → GoesTo k v ((k , v) ∷ xs)
    S : ∀ {v kv xs} → GoesTo k v xs → GoesTo k v (kv ∷ xs)

  KeyIn : {A B : Set} → A → List (A × B) → Set
  KeyIn k kvs = Any (λ kv → fst kv ≡ k) kvs --∀ {v} → GoesTo k v kvs

  KeyIn? : ∀ {A B} {{EqA : Eq A}} (k : A) → (kvs : List (A × B)) → Dec (KeyIn k kvs)
  KeyIn? k [] = no (λ ())
  KeyIn? k (kv ∷ kvs) with fst kv == k
  KeyIn? k (kv ∷ kvs) | yes eq = yes (Z eq)
  KeyIn? k (kv ∷ kvs) | no ¬eq with KeyIn? k kvs
  KeyIn? k (kv ∷ kvs) | no ¬eq | yes ih = yes (S ih)
  KeyIn? k (kv ∷ kvs) | no ¬eq | no ¬ih = no (λ { (Z h) → ¬eq h ; (S h) → ¬ih h})

  lookup : ∀ {A B} {{EqA : Eq A}} {k : A} → {kvs : List (A × B)} → KeyIn k kvs → B
  lookup (Z {._ , b} refl) = b
  lookup (S p) = lookup p

  KeyIn* : {A B : Set} → A → List (List (A × B)) → Set
  KeyIn* k kvss = Any (KeyIn k) kvss

  KeyIn?* : {A B : Set} {{EqA : Eq A}} (k : A) → (kvss : List (List (A × B))) → Dec (KeyIn* k kvss)
  KeyIn?* k [] = no (λ ())
  KeyIn?* k (kvs ∷ kvss) with KeyIn? k kvs
  KeyIn?* k (kvs ∷ kvss) | yes here = yes (Z here)
  KeyIn?* k (kvs ∷ kvss) | no ¬here with KeyIn?* k kvss
  KeyIn?* k (kvs ∷ kvss) | no ¬here | yes there = yes (S there)
  KeyIn?* k (kvs ∷ kvss) | no ¬here | no ¬there = no (λ { (Z h) → ¬here h ; (S h) → ¬there h})

  lookup* : ∀ {A B} {{EqA : Eq A}} {k : A} {kvss : List (List (A × B))} → KeyIn* k kvss → B
  lookup* (Z pf) = lookup pf
  lookup* (S pf) = lookup* pf

  update : ∀ {A B} (k : A) (v : B) kvs → KeyIn k kvs → List (A × B)
  update k v .(x ∷ xs) (Z {x} {xs} x₁) = k , v ∷ xs
  update k v .(x ∷ xs) (S {x} {xs} loc) = x ∷ update k v xs loc

  data Update {A B : Set} (k : A) (v : B) : List (A × B) → List (A × B) → Set where
    Z : ∀ {v′ kvs} → Update k v ((k , v′) ∷ kvs) ((k , v) ∷ kvs)
    S : ∀ {kv kvs kvs′} → Update k v kvs kvs′ → Update k v (kv ∷ kvs) (kv ∷ kvs′)
