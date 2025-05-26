;; Consumer Education Contract
;; Provides sustainability information and educational content

(define-constant err-unauthorized (err u500))
(define-constant err-content-not-found (err u501))
(define-constant err-product-not-found (err u502))

;; Educational content structure
(define-map educational-content
  { content-id: uint }
  {
    title: (string-ascii 100),
    category: (string-ascii 50),
    content: (string-ascii 1000),
    author: principal,
    created-at: uint,
    views: uint,
    rating: uint
  }
)

;; Product sustainability report
(define-map sustainability-reports
  { product-id: uint }
  {
    overall-score: uint,
    carbon-rating: (string-ascii 10),
    water-rating: (string-ascii 10),
    material-rating: (string-ascii 10),
    ethics-rating: (string-ascii 10),
    recyclability: uint,
    durability-score: uint,
    care-instructions: (string-ascii 200)
  }
)

;; Consumer engagement tracking
(define-map consumer-engagement
  { user: principal }
  {
    content-viewed: uint,
    products-researched: uint,
    sustainability-score: uint,
    badges-earned: (list 10 (string-ascii 50))
  }
)

(define-data-var next-content-id uint u1)

;; Create educational content
(define-public (create-content (title (string-ascii 100)) (category (string-ascii 50)) (content (string-ascii 1000)))
  (let ((content-id (var-get next-content-id)))
    (map-set educational-content
      { content-id: content-id }
      {
        title: title,
        category: category,
        content: content,
        author: tx-sender,
        created-at: block-height,
        views: u0,
        rating: u0
      }
    )
    (var-set next-content-id (+ content-id u1))
    (ok content-id)
  )
)

;; Generate sustainability report for product
(define-public (generate-sustainability-report
  (product-id uint)
  (overall-score uint)
  (carbon-rating (string-ascii 10))
  (water-rating (string-ascii 10))
  (material-rating (string-ascii 10))
  (ethics-rating (string-ascii 10))
  (recyclability uint)
  (durability-score uint)
  (care-instructions (string-ascii 200))
)
  (begin
    (map-set sustainability-reports
      { product-id: product-id }
      {
        overall-score: overall-score,
        carbon-rating: carbon-rating,
        water-rating: water-rating,
        material-rating: material-rating,
        ethics-rating: ethics-rating,
        recyclability: recyclability,
        durability-score: durability-score,
        care-instructions: care-instructions
      }
    )
    (ok true)
  )
)

;; View educational content
(define-public (view-content (content-id uint))
  (match (map-get? educational-content { content-id: content-id })
    content-data
    (begin
      (map-set educational-content
        { content-id: content-id }
        (merge content-data { views: (+ (get views content-data) u1) })
      )
      ;; Update user engagement
      (match (map-get? consumer-engagement { user: tx-sender })
        user-data
        (map-set consumer-engagement
          { user: tx-sender }
          (merge user-data { content-viewed: (+ (get content-viewed user-data) u1) })
        )
        (map-set consumer-engagement
          { user: tx-sender }
          {
            content-viewed: u1,
            products-researched: u0,
            sustainability-score: u0,
            badges-earned: (list)
          }
        )
      )
      (ok content-data)
    )
    err-content-not-found
  )
)

;; Research product sustainability
(define-public (research-product (product-id uint))
  (match (map-get? sustainability-reports { product-id: product-id })
    report-data
    (begin
      ;; Update user engagement
      (match (map-get? consumer-engagement { user: tx-sender })
        user-data
        (map-set consumer-engagement
          { user: tx-sender }
          (merge user-data { products-researched: (+ (get products-researched user-data) u1) })
        )
        (map-set consumer-engagement
          { user: tx-sender }
          {
            content-viewed: u0,
            products-researched: u1,
            sustainability-score: u0,
            badges-earned: (list)
          }
        )
      )
      (ok report-data)
    )
    err-product-not-found
  )
)

;; Get educational content
(define-read-only (get-content (content-id uint))
  (map-get? educational-content { content-id: content-id })
)

;; Get sustainability report
(define-read-only (get-sustainability-report (product-id uint))
  (map-get? sustainability-reports { product-id: product-id })
)

;; Get consumer engagement
(define-read-only (get-consumer-engagement (user principal))
  (map-get? consumer-engagement { user: user })
)
