;; Material Sourcing Contract
;; Records sustainable textile origins and certifications

(define-constant err-unauthorized (err u300))
(define-constant err-material-not-found (err u301))
(define-constant err-supplier-not-found (err u302))

;; Supplier data structure
(define-map suppliers
  { supplier-id: uint }
  {
    name: (string-ascii 100),
    location: (string-ascii 100),
    certifications: (list 10 (string-ascii 50)),
    sustainability-rating: uint,
    verified: bool
  }
)

;; Material data structure
(define-map materials
  { material-id: uint }
  {
    name: (string-ascii 100),
    supplier-id: uint,
    origin-country: (string-ascii 50),
    organic: bool,
    recycled-content: uint,
    carbon-footprint: uint,
    water-footprint: uint,
    certification-level: uint
  }
)

;; Product-material mapping
(define-map product-materials
  { product-id: uint, material-id: uint }
  {
    quantity: uint,
    percentage: uint
  }
)

(define-data-var next-supplier-id uint u1)
(define-data-var next-material-id uint u1)

;; Register a supplier
(define-public (register-supplier (name (string-ascii 100)) (location (string-ascii 100)) (certifications (list 10 (string-ascii 50))))
  (let ((supplier-id (var-get next-supplier-id)))
    (map-set suppliers
      { supplier-id: supplier-id }
      {
        name: name,
        location: location,
        certifications: certifications,
        sustainability-rating: u0,
        verified: false
      }
    )
    (var-set next-supplier-id (+ supplier-id u1))
    (ok supplier-id)
  )
)

;; Register a material
(define-public (register-material
  (name (string-ascii 100))
  (supplier-id uint)
  (origin-country (string-ascii 50))
  (organic bool)
  (recycled-content uint)
  (carbon-footprint uint)
  (water-footprint uint)
  (certification-level uint)
)
  (let ((material-id (var-get next-material-id)))
    (asserts! (is-some (map-get? suppliers { supplier-id: supplier-id })) err-supplier-not-found)
    (map-set materials
      { material-id: material-id }
      {
        name: name,
        supplier-id: supplier-id,
        origin-country: origin-country,
        organic: organic,
        recycled-content: recycled-content,
        carbon-footprint: carbon-footprint,
        water-footprint: water-footprint,
        certification-level: certification-level
      }
    )
    (var-set next-material-id (+ material-id u1))
    (ok material-id)
  )
)

;; Link material to product
(define-public (link-material-to-product (product-id uint) (material-id uint) (quantity uint) (percentage uint))
  (begin
    (asserts! (is-some (map-get? materials { material-id: material-id })) err-material-not-found)
    (map-set product-materials
      { product-id: product-id, material-id: material-id }
      {
        quantity: quantity,
        percentage: percentage
      }
    )
    (ok true)
  )
)

;; Get material information
(define-read-only (get-material (material-id uint))
  (map-get? materials { material-id: material-id })
)

;; Get supplier information
(define-read-only (get-supplier (supplier-id uint))
  (map-get? suppliers { supplier-id: supplier-id })
)

;; Get product materials
(define-read-only (get-product-material (product-id uint) (material-id uint))
  (map-get? product-materials { product-id: product-id, material-id: material-id })
)
