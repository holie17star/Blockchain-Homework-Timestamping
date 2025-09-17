(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-assignment (err u103))
(define-constant err-deadline-passed (err u104))
(define-constant err-not-student (err u105))
(define-constant err-duplicate-submission (err u106))
(define-constant err-invalid-hash (err u107))

(define-data-var assignment-counter uint u0)

(define-map assignments
  { assignment-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    instructor: principal,
    deadline-block: uint,
    max-score: uint,
    created-at: uint,
    active: bool
  }
)

(define-map students
  { student-address: principal }
  {
    name: (string-ascii 50),
    student-id: (string-ascii 20),
    registered-at: uint,
    active: bool
  }
)

(define-map submissions
  { assignment-id: uint, student-address: principal }
  {
    content-hash: (buff 32),
    submission-title: (string-ascii 100),
    submitted-at: uint,
    submission-block: uint,
    score: (optional uint),
    graded: bool,
    plagiarism-flag: bool
  }
)

(define-map instructors
  { instructor-address: principal }
  {
    name: (string-ascii 50),
    department: (string-ascii 50),
    registered-at: uint,
    active: bool
  }
)

(define-map assignment-submissions-count
  { assignment-id: uint }
  { count: uint }
)

(define-map plagiarism-reports
  { report-id: uint }
  {
    assignment-id: uint,
    original-student: principal,
    accused-student: principal,
    similarity-score: uint,
    reported-by: principal,
    reported-at: uint,
    resolved: bool
  }
)

(define-data-var plagiarism-report-counter uint u0)

(define-public (register-instructor (name (string-ascii 50)) (department (string-ascii 50)))
  (let ((instructor-data {
    name: name,
    department: department,
    registered-at: stacks-block-height,
    active: true
  }))
  (ok (map-set instructors { instructor-address: tx-sender } instructor-data)))
)

(define-public (register-student (name (string-ascii 50)) (student-id (string-ascii 20)))
  (let ((student-data {
    name: name,
    student-id: student-id,
    registered-at: stacks-block-height,
    active: true
  }))
  (ok (map-set students { student-address: tx-sender } student-data)))
)

(define-public (create-assignment 
  (title (string-ascii 100))
  (description (string-ascii 500))
  (deadline-blocks uint)
  (max-score uint))
  (let ((assignment-id (+ (var-get assignment-counter) u1))
        (assignment-data {
          title: title,
          description: description,
          instructor: tx-sender,
          deadline-block: (+ stacks-block-height deadline-blocks),
          max-score: max-score,
          created-at: stacks-block-height,
          active: true
        }))
    (begin
      (var-set assignment-counter assignment-id)
      (map-set assignments { assignment-id: assignment-id } assignment-data)
      (map-set assignment-submissions-count { assignment-id: assignment-id } { count: u0 })
      (ok assignment-id)))
)

(define-public (submit-assignment 
  (assignment-id uint)
  (content-hash (buff 32))
  (submission-title (string-ascii 100)))
  (let ((assignment-opt (map-get? assignments { assignment-id: assignment-id }))
        (student-opt (map-get? students { student-address: tx-sender }))
        (existing-submission (map-get? submissions { assignment-id: assignment-id, student-address: tx-sender })))
    (match assignment-opt
      assignment-info
      (match student-opt
        student-info
        (if (get active student-info)
          (if (< stacks-block-height (get deadline-block assignment-info))
            (if (is-none existing-submission)
              (if (> (len content-hash) u0)
                (let ((submission-data {
                  content-hash: content-hash,
                  submission-title: submission-title,
                  submitted-at: stacks-block-height,
                  submission-block: stacks-block-height,
                  score: none,
                  graded: false,
                  plagiarism-flag: false
                })
                (current-count (default-to { count: u0 } (map-get? assignment-submissions-count { assignment-id: assignment-id }))))
                (begin
                  (map-set submissions { assignment-id: assignment-id, student-address: tx-sender } submission-data)
                  (map-set assignment-submissions-count { assignment-id: assignment-id } { count: (+ (get count current-count) u1) })
                  (ok true)))
                err-invalid-hash)
              err-duplicate-submission)
            err-deadline-passed)
          err-not-student)
        err-not-student)
      err-invalid-assignment))
)

(define-public (grade-submission 
  (assignment-id uint)
  (student-address principal)
  (score uint))
  (let ((assignment-opt (map-get? assignments { assignment-id: assignment-id }))
        (submission-opt (map-get? submissions { assignment-id: assignment-id, student-address: student-address })))
    (match assignment-opt
      assignment-info
      (if (is-eq tx-sender (get instructor assignment-info))
        (match submission-opt
          submission-info
          (if (<= score (get max-score assignment-info))
            (let ((updated-submission (merge submission-info { score: (some score), graded: true })))
              (ok (map-set submissions { assignment-id: assignment-id, student-address: student-address } updated-submission)))
            (err u108))
          err-not-found)
        err-owner-only)
      err-invalid-assignment))
)

(define-public (report-plagiarism 
  (assignment-id uint)
  (original-student principal)
  (accused-student principal)
  (similarity-score uint))
  (let ((report-id (+ (var-get plagiarism-report-counter) u1))
        (report-data {
          assignment-id: assignment-id,
          original-student: original-student,
          accused-student: accused-student,
          similarity-score: similarity-score,
          reported-by: tx-sender,
          reported-at: stacks-block-height,
          resolved: false
        }))
    (begin
      (var-set plagiarism-report-counter report-id)
      (map-set plagiarism-reports { report-id: report-id } report-data)
      (ok report-id)))
)

(define-public (flag-plagiarism 
  (assignment-id uint)
  (student-address principal))
  (let ((assignment-opt (map-get? assignments { assignment-id: assignment-id }))
        (submission-opt (map-get? submissions { assignment-id: assignment-id, student-address: student-address })))
    (match assignment-opt
      assignment-info
      (if (is-eq tx-sender (get instructor assignment-info))
        (match submission-opt
          submission-info
          (let ((updated-submission (merge submission-info { plagiarism-flag: true })))
            (ok (map-set submissions { assignment-id: assignment-id, student-address: student-address } updated-submission)))
          err-not-found)
        err-owner-only)
      err-invalid-assignment))
)

(define-public (deactivate-assignment (assignment-id uint))
  (let ((assignment-opt (map-get? assignments { assignment-id: assignment-id })))
    (match assignment-opt
      assignment-info
      (if (is-eq tx-sender (get instructor assignment-info))
        (let ((updated-assignment (merge assignment-info { active: false })))
          (ok (map-set assignments { assignment-id: assignment-id } updated-assignment)))
        err-owner-only)
      err-invalid-assignment))
)

(define-read-only (get-assignment (assignment-id uint))
  (map-get? assignments { assignment-id: assignment-id })
)

(define-read-only (get-submission (assignment-id uint) (student-address principal))
  (map-get? submissions { assignment-id: assignment-id, student-address: student-address })
)

(define-read-only (get-student (student-address principal))
  (map-get? students { student-address: student-address })
)

(define-read-only (get-instructor (instructor-address principal))
  (map-get? instructors { instructor-address: instructor-address })
)

(define-read-only (get-assignment-count)
  (var-get assignment-counter)
)

(define-read-only (get-submission-count (assignment-id uint))
  (match (map-get? assignment-submissions-count { assignment-id: assignment-id })
    count-data (get count count-data)
    u0)
)

(define-read-only (verify-submission-timestamp 
  (assignment-id uint)
  (student-address principal))
  (match (map-get? submissions { assignment-id: assignment-id, student-address: student-address })
    submission-info
    (some {
      submitted-at: (get submitted-at submission-info),
      submission-block: (get submission-block submission-info),
      content-hash: (get content-hash submission-info),
      plagiarism-flag: (get plagiarism-flag submission-info)
    })
    none)
)

(define-read-only (check-deadline (assignment-id uint))
  (match (map-get? assignments { assignment-id: assignment-id })
    assignment-info
    (some {
      deadline-block: (get deadline-block assignment-info),
      current-block: stacks-block-height,
      deadline-passed: (>= stacks-block-height (get deadline-block assignment-info))
    })
    none)
)

(define-read-only (get-plagiarism-report (report-id uint))
  (map-get? plagiarism-reports { report-id: report-id })
)

(define-read-only (get-plagiarism-report-count)
  (var-get plagiarism-report-counter)
)

(define-read-only (is-submission-original 
  (assignment-id uint)
  (student-address principal))
  (match (map-get? submissions { assignment-id: assignment-id, student-address: student-address })
    submission-info
    (not (get plagiarism-flag submission-info))
    true)
)
