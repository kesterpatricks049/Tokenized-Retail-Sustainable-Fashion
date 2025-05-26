;; Brand Verification Contract
;; Validates and manages fashion company credentials

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-brand-not-found (err u101))
(define-constant err-brand-already-verified (err u102))

;; Brand data structure
(define-map brands
  { brand-id: uint }
  {
    name: (string-ascii 100),
    owner: principal,
    verified: bool,
    verification-date: uint,
    sustainability-score: uint
  }
)

(define-data-var next-brand-id uint u1)

;; Register a new brand
(define-public (register-brand (name (string-ascii 100)))
  (let ((brand-id (var-get next-brand-id)))
    (map-set brands
      { brand-id: brand-id }
      {
        name: name,
        owner: tx-sender,
        verified: false,
        verification-date: u0,
        sustainability-score: u0
      }
    )
    (var-set next-brand-id (+ brand-id u1))
    (ok brand-id)
  )
)

;; Verify a brand (owner only)
(define-public (verify-brand (brand-id uint) (sustainability-score uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (match (map-get? brands { brand-id: brand-id })
      brand-data
      (begin
        (asserts! (not (get verified brand-data)) err-brand-already-verified)
        (map-set brands
          { brand-id: brand-id }
          (merge brand-data {
            verified: true,
            verification-date: block-height,
            sustainability-score: sustainability-score
          })
        )
        (ok true)
      )
      err-brand-not-found
    )
  )
)

;; Get brand information
(define-read-only (get-brand (brand-id uint))
  (map-get? brands { brand-id: brand-id })
)

;; Check if brand is verified
(define-read-only (is-brand-verified (brand-id uint))
  (match (map-get? brands { brand-id: brand-id })
    brand-data (get verified brand-data)
    false
  )
)
