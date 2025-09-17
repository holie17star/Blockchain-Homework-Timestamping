# 📚 Blockchain Homework Timestamping

A Clarity smart contract that enables students to prove originality and submission time of assignments to combat plagiarism through blockchain timestamping.

## 🎯 Overview

This smart contract provides a decentralized solution for academic integrity by:
- 📝 Allowing students to submit homework with cryptographic proof
- ⏰ Timestamping submissions using blockchain immutability  
- 🛡️ Preventing plagiarism through content hash verification
- 👨‍🏫 Enabling instructors to grade and manage assignments
- 🔍 Providing plagiarism detection and reporting mechanisms

## 🚀 Features

### For Students 👩‍🎓
- **Register** as a student with name and student ID
- **Submit assignments** with content hash and metadata
- **Prove originality** through blockchain timestamps
- **Track submission status** and grades

### For Instructors 👨‍🏫  
- **Register** as an instructor with department info
- **Create assignments** with deadlines and scoring
- **Grade submissions** and provide scores
- **Flag plagiarism** and manage academic integrity
- **Deactivate assignments** when needed

### For Everyone 🌍
- **Verify timestamps** of any submission
- **Check deadlines** and assignment status
- **Report plagiarism** with similarity scores
- **View assignment and submission data**

## 📋 Contract Functions

### Public Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `register-student` | Register as a student | `name`, `student-id` |
| `register-instructor` | Register as an instructor | `name`, `department` |
| `create-assignment` | Create new assignment | `title`, `description`, `deadline-blocks`, `max-score` |
| `submit-assignment` | Submit homework | `assignment-id`, `content-hash`, `submission-title` |
| `grade-submission` | Grade student submission | `assignment-id`, `student-address`, `score` |
| `report-plagiarism` | Report plagiarism case | `assignment-id`, `original-student`, `accused-student`, `similarity-score` |
| `flag-plagiarism` | Flag submission as plagiarized | `assignment-id`, `student-address` |
| `deactivate-assignment` | Deactivate assignment | `assignment-id` |

### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `get-assignment` | Get assignment details | Assignment info |
| `get-submission` | Get submission details | Submission info |
| `get-student` | Get student info | Student data |
| `get-instructor` | Get instructor info | Instructor data |
| `verify-submission-timestamp` | Verify submission timestamp | Timestamp proof |
| `check-deadline` | Check assignment deadline | Deadline status |
| `is-submission-original` | Check if submission is original | Boolean |

## 💡 Usage Examples

### 1️⃣ Student Registration
```clarity
(contract-call? .contract register-student "Alice Johnson" "ALJ001")
```

### 2️⃣ Instructor Registration  
```clarity
(contract-call? .contract register-instructor "Dr. Smith" "Computer Science")
```

### 3️⃣ Create Assignment
```clarity
(contract-call? .contract create-assignment 
  "Data Structures Project" 
  "Implement a binary search tree with documentation"
  u1440  ;; deadline in blocks (approximately 10 days)
  u100)  ;; max score
```

### 4️⃣ Submit Assignment
```clarity
(contract-call? .contract submit-assignment 
  u1  ;; assignment ID
  0x1234567890abcdef...  ;; SHA-256 hash of assignment content
  "BST Implementation with Tests")
```

### 5️⃣ Grade Submission
```clarity
(contract-call? .contract grade-submission u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u85)
```

## 🔒 Security Features

- **Content Hashing**: Submissions are identified by SHA-256 hashes
- **Timestamp Immutability**: Blockchain provides tamper-proof timestamps  
- **Deadline Enforcement**: Automatic deadline checking prevents late submissions
- **Duplicate Prevention**: Each student can only submit once per assignment
- **Access Control**: Only instructors can grade and manage their assignments

## 🛠️ Development

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Basic knowledge of Clarity smart contracts

### Running Tests
```bash
clarinet check
clarinet test
```

### Deployment
```bash
clarinet deploy --testnet
```

## 📊 Data Structures

The contract uses several maps to store data:
- `assignments`: Assignment metadata and settings
- `students`: Student registration information  
- `submissions`: Student homework submissions
- `instructors`: Instructor profiles
- `plagiarism-reports`: Plagiarism reports and investigations

## 🚨 Error Codes

| Code | Description |
|------|-------------|
| u100 | Owner only operation |
| u101 | Not found |
| u102 | Already exists |
| u103 | Invalid assignment |
| u104 | Deadline passed |
| u105 | Not a student |
| u106 | Duplicate submission |
| u107 | Invalid hash |
| u108 | Score exceeds maximum |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests with `clarinet check`
5. Submit a pull request

## 📜 License

This project is open source and available under the MIT License.

## 🎉 Benefits

✅ **Immutable timestamps** prove submission time  
✅ **Content hashing** detects plagiarism  
✅ **Decentralized storage** prevents data manipulation  
✅ **Transparent grading** creates trust between students and instructors  
✅ **Academic integrity** protection for educational institutions  

---

*Built with ❤️ for academic integrity and blockchain innovation*
