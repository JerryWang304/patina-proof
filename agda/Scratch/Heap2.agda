open import Common
module Heap2 where

data Route (#a : ℕ) : Set where
  alloc : Fin #a → Route #a
  * : Route #a → Route #a
  <_>_∙_ : (n : ℕ) → Route #a → Fin n → Route #a
  disc : Route #a → Route #a
  pay : Route #a → Route #a

data Value (A : Set) : Set where
  void : Value A
  val : A → Value A

data Layout (#a : ℕ) : Set where
  int : Value ℕ → Layout #a
  ptr : Value (Route #a) → Layout #a
  opt : Layout #a → Layout #a → Layout #a
  rec : ∀ {n} → Vec (Layout #a) n → Layout #a

record Allocation (#a : ℕ) : Set where
  constructor alloc
  field
    contents : Layout #a
open Allocation

Heap : ℕ → Set
Heap n = Vec (Allocation n) n

test-H : Heap 13
test-H = {-  0 -} [  alloc (int (val 22))
         {-  1 -} ,, alloc (ptr (val (alloc (fin′′ 12))))
         {-  2 -} ,, alloc (rec ([ int (val 23) ]))
         {-  3 -} ,, alloc (rec ([ int (val 24)
                                ,, ptr (val (alloc (fin′′ 11))) ]))
         {-  4 -} ,, alloc (rec ([ rec ([ int (val 25) ])
                                ,, rec ([ int (val 26)
                                       ,, ptr (val (alloc (fin′′ 10))) ]) ]))
         {-  5 -} ,, alloc (ptr (val (alloc (fin′′ 11))))
         {-  6 -} ,, alloc (ptr (val (alloc (fin′′ 9))))
         {-  7 -} ,, alloc (opt (int (val 1))
                                (ptr (val (alloc (fin′′ 8)))))
         {-  8 -} ,, alloc (int (val 31))
         {-  9 -} ,, alloc (int (val 30))
         {- 10 -} ,, alloc (int (val 29))
         {- 11 -} ,, alloc (int (val 28))
         {- 12 -} ,, alloc (int (val 27))
         ]

data _⊢_⇒_ {#a} : Heap #a → Route #a → Layout #a → Set where
  alloc : ∀ {H α} → H ⊢ alloc α ⇒ contents (H ! α)
  * : ∀ {H r r′ l} → H ⊢ r ⇒ ptr (val r′) → H ⊢ r′ ⇒ l → H ⊢ * r ⇒ l
  ∙ : ∀ {H r n f ls} → H ⊢ r ⇒ rec ls → H ⊢ < n > r ∙ f ⇒ (ls ! f)
  disc : ∀ {H r d p} → H ⊢ r ⇒ opt d p → H ⊢ disc r ⇒ d
  pay : ∀ {H r d p} → H ⊢ r ⇒ opt d p → H ⊢ pay r ⇒ p

test-deref-1 : test-H ⊢ alloc (fin 0) ⇒ int (val 22)
test-deref-1 = alloc
test-deref-2 : test-H ⊢ alloc (fin 1) ⇒ ptr (val (alloc (fin 12)))
test-deref-2 = alloc
test-deref-3 : test-H ⊢ * (alloc (fin 1)) ⇒ int (val 27)
test-deref-3 = * alloc alloc
test-deref-4 : test-H ⊢ alloc (fin 2) ⇒ rec ([ int (val 23) ])
test-deref-4 = alloc
test-deref-5 : test-H ⊢ < 1 > alloc (fin 2) ∙ fin 0 ⇒ int (val 23)
test-deref-5 = ∙ alloc
test-deref-6 : test-H ⊢ alloc (fin 3) ⇒ rec ([ int (val 24) ,, ptr (val (alloc (fin 11))) ])
test-deref-6 = alloc
test-deref-7 : test-H ⊢ < 2 > alloc (fin 3) ∙ fin 0 ⇒ int (val 24)
test-deref-7 = ∙ alloc
test-deref-8 : test-H ⊢ < 2 > alloc (fin 3) ∙ fin 1 ⇒ ptr (val (alloc (fin 11)))
test-deref-8 = ∙ alloc
test-deref-9 : test-H ⊢ * (< 2 > alloc (fin 3) ∙ fin 1) ⇒ int (val 28)
test-deref-9 = * (∙ alloc) alloc
test-deref-10 : test-H ⊢ alloc (fin 4) ⇒ rec ([ rec ([ int (val 25) ]) ,, rec ([ int (val 26) ,, ptr (val (alloc (fin 10))) ]) ])
test-deref-10 = alloc
test-deref-11 : test-H ⊢ < 2 > alloc (fin 4) ∙ fin 0 ⇒ rec ([ int (val 25) ])
test-deref-11 = ∙ alloc
test-deref-12 : test-H ⊢ < 1 > < 2 > alloc (fin 4) ∙ fin 0 ∙ fin 0 ⇒ int (val 25)
test-deref-12 = ∙ (∙ alloc)
test-deref-13 : test-H ⊢ < 2 > alloc (fin 4) ∙ fin 1 ⇒ rec ([ int (val 26) ,, ptr (val (alloc (fin 10))) ])
test-deref-13 = ∙ alloc
test-deref-14 : test-H ⊢ < 2 > < 2 > alloc (fin 4) ∙ fin 1 ∙ fin 0 ⇒ int (val 26)
test-deref-14 = ∙ (∙ alloc)
test-deref-15 : test-H ⊢ < 2 > < 2 > alloc (fin 4) ∙ fin 1 ∙ fin 1 ⇒ ptr (val (alloc (fin 10)))
test-deref-15 = ∙ (∙ alloc)
test-deref-16 : test-H ⊢ * (< 2 > < 2 > alloc (fin 4) ∙ fin 1 ∙ fin 1) ⇒ int (val 29)
test-deref-16 = * (∙ (∙ alloc)) alloc
test-deref-17 : test-H ⊢ alloc (fin 5) ⇒ ptr (val (alloc (fin 11)))
test-deref-17 = alloc
test-deref-18 : test-H ⊢ * (alloc (fin 5)) ⇒ int (val 28)
test-deref-18 = * alloc alloc
test-deref-19 : test-H ⊢ alloc (fin 6) ⇒ ptr (val (alloc (fin 9)))
test-deref-19 = alloc
test-deref-20 : test-H ⊢ * (alloc (fin 6)) ⇒ int (val 30)
test-deref-20 = * alloc alloc
test-deref-21 : test-H ⊢ alloc (fin 7) ⇒ opt (int (val 1)) (ptr (val (alloc (fin 8))))
test-deref-21 = alloc
test-deref-22 : test-H ⊢ disc (alloc (fin 7)) ⇒ int (val 1)
test-deref-22 = disc alloc
test-deref-23 : test-H ⊢ pay (alloc (fin 7)) ⇒ ptr (val (alloc (fin 8)))
test-deref-23 = pay alloc
test-deref-24 : test-H ⊢ * (pay (alloc (fin 7))) ⇒ int (val 31)
test-deref-24 = * (pay alloc) alloc

data _⊢_≔_⇒_ {#a} : Heap #a → Route #a → Layout #a → Heap #a → Set where
  alloc : ∀ {H α l} → H ⊢ alloc α ≔ l ⇒ set H α (alloc l)
  * : ∀ {H r r′ l H′} → H ⊢ r ⇒ ptr (val r′) → H ⊢ r′ ≔ l ⇒ H′ → H ⊢ * r ≔ l ⇒ H′
  ∙ : ∀ {H r n f ls l H′}
    → H ⊢ r ⇒ rec ls
    → H ⊢ r ≔ rec (set ls f l) ⇒ H′
    → H ⊢ < n > r ∙ f ≔ l ⇒ H′
  disc : ∀ {H r d p l H′}
       → H ⊢ r ⇒ opt d p
       → H ⊢ r ≔ opt l p ⇒ H′
       → H ⊢ disc r ≔ l ⇒ H′
  pay : ∀ {H r d p l H′}
      → H ⊢ r ⇒ opt d p
      → H ⊢ r ≔ opt d l ⇒ H′
      → H ⊢ pay r ≔ l ⇒ H′

test-write-1 : ([ alloc (int void) ]) ⊢ alloc (fin 0) ≔ int void ⇒ ([ alloc (int void) ])
test-write-1 = alloc
test-write-2 : ([ alloc (ptr (val (alloc (fin 1)))) ,, alloc (int (val 1)) ])
               ⊢ alloc (fin 0) ≔ ptr void
               ⇒ ([ alloc (ptr void) ,, alloc (int (val 1)) ])
test-write-2 = alloc
test-write-3 : ([ alloc (ptr (val (alloc (fin 1)))) ,, alloc (int (val 1)) ])
               ⊢ * (alloc (fin 0)) ≔ int void
               ⇒ ([ alloc (ptr (val (alloc (fin 1)))) ,, alloc (int void) ])
test-write-3 = * alloc alloc
test-write-4 : ([ alloc (ptr (val (alloc (fin 1)))) ,, alloc (int (val 1)) ])
               ⊢ alloc (fin 0) ≔ ptr void
               ⇒ ([ alloc (ptr void) ,, alloc (int (val 1)) ])
test-write-4 = alloc
test-write-5 : ([ alloc (ptr (val (alloc (fin 1)))) ,, alloc (int (val 1)) ])
               ⊢ * (alloc (fin 0)) ≔ int void
               ⇒ ([ alloc (ptr (val (alloc (fin 1)))) ,, alloc (int void) ])
test-write-5 = * alloc alloc
test-write-6 : ([ alloc (rec ([ int (val 0) ,, int (val 1) ])) ])
               ⊢ < 2 > alloc fZ ∙ fin 0 ≔ int void
               ⇒ ([ alloc (rec ([ int void ,, int (val 1) ])) ])
test-write-6 = ∙ alloc alloc
test-write-7 : ([ alloc (rec ([ int (val 0) ,, int (val 1) ])) ])
               ⊢ < 2 > alloc fZ ∙ fin 1 ≔ int void
               ⇒ ([ alloc (rec ([ int (val 0) ,, int void ])) ])
test-write-7 = ∙ alloc alloc
test-write-8 : ([ alloc (opt (int (val 1)) (int (val 10))) ])
               ⊢ disc (alloc fZ) ≔ int void
               ⇒ ([ alloc (opt (int void) (int (val 10))) ])
test-write-8 = disc alloc alloc
test-write-9 : ([ alloc (opt (int (val 1)) (int (val 10))) ])
               ⊢ pay (alloc fZ) ≔ int void
               ⇒ ([ alloc (opt (int (val 1)) (int void)) ])
test-write-9 = pay alloc alloc

_⊢_to_⇒_ : ∀ {#a} → Heap #a → Route #a → Route #a → Heap #a → Set
H ⊢ src to dst ⇒ H′ = Σ[ l ∈ Layout _ ] H ⊢ src ⇒ l × H ⊢ dst ≔ l ⇒ H′

test-memcopy-1 : ([ alloc (opt (int (val 1)) (int (val 10)))
                 ,, alloc (opt (int (val 0)) (int void)) ])
               ⊢ alloc (fin 0) to alloc (fin 1)
               ⇒ ([ alloc (opt (int (val 1)) (int (val 10)))
                 ,, alloc (opt (int (val 1)) (int (val 10))) ])
test-memcopy-1 = opt (int (val 1))
                   (int (val 10))
                   , (alloc , alloc)

data Type : Set where
  int : Type
  ~ : Type → Type
  & : Type → Type
  opt : Type → Type
  rec : ∀ {n} → Vec Type n → Type

data _⊢_∶_route {#a} (σ : Vec Type #a) : Route #a → Type → Set where
  alloc : ∀ {α} → σ ⊢ alloc α ∶ σ ! α route
  *~ : ∀ {r τ} → σ ⊢ r ∶ ~ τ route → σ ⊢ * r ∶ τ route
  *& : ∀ {r τ} → σ ⊢ r ∶ & τ route → σ ⊢ * r ∶ τ route
  ∙ : ∀ {n r f τs} → σ ⊢ r ∶ rec τs route → σ ⊢ < n > r ∙ f ∶ τs ! f route
  disc : ∀ {r τ} → σ ⊢ r ∶ opt τ route → σ ⊢ disc r ∶ int route
  pay : ∀ {r τ} → σ ⊢ r ∶ opt τ route → σ ⊢ pay r ∶ τ route

data _⊢_∶_layout {#a} (σ : Vec Type #a) : Layout #a → Type → Set where
  int : ∀ {n} → σ ⊢ int n ∶ int layout
  ptr~ : ∀ {r τ} → σ ⊢ r ∶ τ route → σ ⊢ ptr (val r) ∶ ~ τ layout
  ⊥~ : ∀ {τ} → σ ⊢ ptr void ∶ ~ τ layout
  ptr& : ∀ {r τ} → σ ⊢ r ∶ τ route → σ ⊢ ptr (val r) ∶ & τ layout
  ⊥& : ∀ {τ} → σ ⊢ ptr void ∶ & τ layout
  opt : ∀ {τ d p} → σ ⊢ d ∶ int layout → σ ⊢ p ∶ τ layout → σ ⊢ opt d p ∶ opt τ layout
  rec : ∀ {n} {ls : Vec (Layout #a) n} {τs : Vec Type n}
      → All (λ {(l , τ) → σ ⊢ l ∶ τ layout}) (zip ls τs)
      → σ ⊢ rec ls ∶ rec τs layout

_⊢_∶_alloc : ∀ {#a} → Vec Type #a → Allocation #a → Type → Set
σ ⊢ alloc l ∶ τ alloc = σ ⊢ l ∶ τ layout

_⊢_heap : ∀ {#a} → Vec Type #a → Heap #a → Set
σ ⊢ H heap = All (λ {(τ , α) → σ ⊢ α ∶ τ alloc }) (zip σ H)

test-σ : Vec Type 13
test-σ = [  int
         ,, ~ int
         ,, rec ([ int ])
         ,, rec ([ int ,, & int ])
         ,, rec ([ rec ([ int ]) ,, rec ([ int ,, & int ]) ])
         ,, & int
         ,, ~ int
         ,, opt (~ int)
         ,, int
         ,, int
         ,, int
         ,, int
         ,, int
         ]

test-HT : test-σ ⊢ test-H heap
test-HT = int
        ∷ ptr~ alloc
        ∷ rec (int ∷ [])
        ∷ rec (int ∷ ptr& alloc  ∷ [])
        ∷ rec ((rec (int ∷ [])) ∷ (rec (int ∷ (ptr& alloc ∷ []))) ∷ [])
        ∷ ptr& alloc
        ∷ ptr~ alloc
        ∷ opt int (ptr~ alloc)
        ∷ int
        ∷ int
        ∷ int
        ∷ int
        ∷ int
        ∷ []

