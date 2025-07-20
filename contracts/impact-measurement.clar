;; Impact Measurement Contract
;; Tracks cleanup effectiveness and ocean health metrics

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u400))
(define-constant ERR-INVALID-INPUT (err u401))
(define-constant ERR-REGION-NOT-FOUND (err u402))
(define-constant ERR-MEASUREMENT-NOT-FOUND (err u403))
(define-constant ERR-INSUFFICIENT-DATA (err u404))

;; Data Variables
(define-data-var next-region-id uint u1)
(define-data-var next-measurement-id uint u1)
(define-data-var global-impact-score uint u0)
(define-data-var total-waste-removed uint u0)

;; Data Maps
(define-map ocean-regions
  uint
  {
    name: (string-ascii 100),
    min-latitude: int,
    max-latitude: int,
    min-longitude: int,
    max-longitude: int,
    baseline-pollution-level: uint,
    current-pollution-level: uint,
    total-cleanup-operations: uint,
    total-waste-removed: uint,
    health-improvement-score: uint,
    last-assessment-date: uint
  }
)

(define-map impact-measurements
  uint
  {
    region-id: uint,
    measurement-date: uint,
    pollution-level: uint,
    biodiversity-index: uint,
    water-quality-score: uint,
    waste-density: uint,
    cleanup-effectiveness: uint,
    verifier: principal,
    verification-status: bool,
    measurement-type: (string-ascii 30)
  }
)

(define-map cleanup-impact-records
  uint
  {
    vessel-assignment-id: uint,
    region-id: uint,
    waste-removed: uint,
    area-cleaned: uint,
    before-pollution-level: uint,
    after-pollution-level: uint,
    impact-score: uint,
    cleanup-date: uint,
    verification-status: bool
  }
)

(define-map verifier-credentials
  principal
  {
    organization: (string-ascii 100),
    certification-level: uint,
    total-verifications: uint,
    accuracy-rating: uint,
    specialization: (string-ascii 50),
    active-status: bool
  }
)

;; Public Functions

;; Register a new ocean region for monitoring
(define-public (register-region (name (string-ascii 100)) (min-lat int) (max-lat int) (min-lon int) (max-lon int) (baseline-pollution uint))
  (let
    (
      (region-id (var-get next-region-id))
    )
    (asserts! (< min-lat max-lat) ERR-INVALID-INPUT)
    (asserts! (< min-lon max-lon) ERR-INVALID-INPUT)
    (asserts! (and (>= min-lat -90000000) (<= max-lat 90000000)) ERR-INVALID-INPUT)
    (asserts! (and (>= min-lon -180000000) (<= max-lon 180000000)) ERR-INVALID-INPUT)
    (asserts! (<= baseline-pollution u1000) ERR-INVALID-INPUT)

    ;; Create region record
    (map-set ocean-regions region-id
      {
        name: name,
        min-latitude: min-lat,
        max-latitude: max-lat,
        min-longitude: min-lon,
        max-longitude: max-lon,
        baseline-pollution-level: baseline-pollution,
        current-pollution-level: baseline-pollution,
        total-cleanup-operations: u0,
        total-waste-removed: u0,
        health-improvement-score: u0,
        last-assessment-date: block-height
      }
    )

    ;; Increment region ID
    (var-set next-region-id (+ region-id u1))

    (ok region-id)
  )
)

;; Record impact measurement
(define-public (record-measurement (region-id uint) (pollution-level uint) (biodiversity-index uint) (water-quality uint) (waste-density uint) (measurement-type (string-ascii 30)))
  (let
    (
      (region (unwrap! (map-get? ocean-regions region-id) ERR-REGION-NOT-FOUND))
      (measurement-id (var-get next-measurement-id))
      (cleanup-effectiveness (calculate-cleanup-effectiveness (get baseline-pollution-level region) pollution-level))
    )
    (asserts! (<= pollution-level u1000) ERR-INVALID-INPUT)
    (asserts! (<= biodiversity-index u1000) ERR-INVALID-INPUT)
    (asserts! (<= water-quality u1000) ERR-INVALID-INPUT)
    (asserts! (<= waste-density u1000) ERR-INVALID-INPUT)

    ;; Create measurement record
    (map-set impact-measurements measurement-id
      {
        region-id: region-id,
        measurement-date: block-height,
        pollution-level: pollution-level,
        biodiversity-index: biodiversity-index,
        water-quality-score: water-quality,
        waste-density: waste-density,
        cleanup-effectiveness: cleanup-effectiveness,
        verifier: tx-sender,
        verification-status: false,
        measurement-type: measurement-type
      }
    )

    ;; Update region current pollution level
    (map-set ocean-regions region-id
      (merge region {
        current-pollution-level: pollution-level,
        last-assessment-date: block-height
      })
    )

    ;; Increment measurement ID
    (var-set next-measurement-id (+ measurement-id u1))

    (ok measurement-id)
  )
)

;; Record cleanup impact
(define-public (record-cleanup-impact (vessel-assignment-id uint) (region-id uint) (waste-removed uint) (area-cleaned uint) (before-pollution uint) (after-pollution uint))
  (let
    (
      (region (unwrap! (map-get? ocean-regions region-id) ERR-REGION-NOT-FOUND))
      (impact-score (calculate-impact-score waste-removed area-cleaned before-pollution after-pollution))
    )
    (asserts! (> waste-removed u0) ERR-INVALID-INPUT)
    (asserts! (> area-cleaned u0) ERR-INVALID-INPUT)
    (asserts! (>= before-pollution after-pollution) ERR-INVALID-INPUT)

    ;; Create cleanup impact record
    (map-set cleanup-impact-records vessel-assignment-id
      {
        vessel-assignment-id: vessel-assignment-id,
        region-id: region-id,
        waste-removed: waste-removed,
        area-cleaned: area-cleaned,
        before-pollution-level: before-pollution,
        after-pollution-level: after-pollution,
        impact-score: impact-score,
        cleanup-date: block-height,
        verification-status: false
      }
    )

    ;; Update region statistics
    (map-set ocean-regions region-id
      (merge region {
        total-cleanup-operations: (+ (get total-cleanup-operations region) u1),
        total-waste-removed: (+ (get total-waste-removed region) waste-removed),
        health-improvement-score: (+ (get health-improvement-score region) impact-score)
      })
    )

    ;; Update global statistics
    (var-set total-waste-removed (+ (var-get total-waste-removed) waste-removed))
    (var-set global-impact-score (+ (var-get global-impact-score) impact-score))

    (ok impact-score)
  )
)

;; Verify measurement or impact record
(define-public (verify-measurement (measurement-id uint) (is-valid bool))
  (let
    (
      (measurement (unwrap! (map-get? impact-measurements measurement-id) ERR-MEASUREMENT-NOT-FOUND))
      (verifier-creds (map-get? verifier-credentials tx-sender))
    )
    (asserts! (is-some verifier-creds) ERR-NOT-AUTHORIZED)
    (asserts! (get active-status (unwrap-panic verifier-creds)) ERR-NOT-AUTHORIZED)
    (asserts! (not (get verification-status measurement)) ERR-INVALID-INPUT)

    ;; Update measurement verification
    (map-set impact-measurements measurement-id
      (merge measurement {
        verification-status: is-valid
      })
    )

    ;; Update verifier stats
    (update-verifier-stats tx-sender)

    (ok is-valid)
  )
)

;; Register as impact verifier
(define-public (register-verifier (organization (string-ascii 100)) (certification-level uint) (specialization (string-ascii 50)))
  (begin
    (asserts! (and (> certification-level u0) (<= certification-level u5)) ERR-INVALID-INPUT)

    (map-set verifier-credentials tx-sender
      {
        organization: organization,
        certification-level: certification-level,
        total-verifications: u0,
        accuracy-rating: u100,
        specialization: specialization,
        active-status: true
      }
    )

    (ok true)
  )
)

;; Get region information
(define-read-only (get-region (region-id uint))
  (map-get? ocean-regions region-id)
)

;; Get measurement information
(define-read-only (get-measurement (measurement-id uint))
  (map-get? impact-measurements measurement-id)
)

;; Get cleanup impact record
(define-read-only (get-cleanup-impact (vessel-assignment-id uint))
  (map-get? cleanup-impact-records vessel-assignment-id)
)

;; Get global impact statistics
(define-read-only (get-global-impact-stats)
  (ok {
    global-impact-score: (var-get global-impact-score),
    total-waste-removed: (var-get total-waste-removed),
    total-regions: (var-get next-region-id),
    total-measurements: (var-get next-measurement-id)
  })
)

;; Get region health trend
(define-read-only (get-region-health-trend (region-id uint))
  (let
    (
      (region (unwrap! (map-get? ocean-regions region-id) ERR-REGION-NOT-FOUND))
      (baseline (get baseline-pollution-level region))
      (current (get current-pollution-level region))
      (improvement-percentage (if (> baseline u0)
                               (/ (* (- baseline current) u100) baseline)
                               u0))
    )
    (ok {
      baseline-pollution: baseline,
      current-pollution: current,
      improvement-percentage: improvement-percentage,
      health-score: (get health-improvement-score region),
      total-operations: (get total-cleanup-operations region)
    })
  )
)

;; Private Functions

;; Calculate cleanup effectiveness
(define-private (calculate-cleanup-effectiveness (baseline uint) (current uint))
  (if (> baseline u0)
    (/ (* (- baseline current) u100) baseline)
    u0
  )
)

;; Calculate impact score
(define-private (calculate-impact-score (waste-removed uint) (area-cleaned uint) (before-pollution uint) (after-pollution uint))
  (let
    (
      (waste-factor (* waste-removed u10))
      (area-factor (* area-cleaned u5))
      (pollution-reduction (* (- before-pollution after-pollution) u20))
    )
    (/ (+ waste-factor area-factor pollution-reduction) u3)
  )
)

;; Update verifier statistics
(define-private (update-verifier-stats (verifier principal))
  (let
    (
      (current-creds (unwrap-panic (map-get? verifier-credentials verifier)))
    )
    (map-set verifier-credentials verifier
      (merge current-creds {
        total-verifications: (+ (get total-verifications current-creds) u1)
      })
    )
  )
)

;; Admin Functions

;; Deactivate verifier (admin only)
(define-public (deactivate-verifier (verifier principal))
  (let
    (
      (verifier-creds (unwrap! (map-get? verifier-credentials verifier) ERR-NOT-AUTHORIZED))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set verifier-credentials verifier
      (merge verifier-creds {
        active-status: false
      })
    )

    (ok true)
  )
)
