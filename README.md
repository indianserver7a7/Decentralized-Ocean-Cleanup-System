# Decentralized Ocean Cleanup System

A blockchain-based system for coordinating global ocean cleanup efforts, tracking pollution, managing cleanup vessels, processing waste, measuring impact, and distributing funding.

## System Overview

The Decentralized Ocean Cleanup System consists of five interconnected smart contracts:

### 1. Pollution Detection Contract (`pollution-detection.clar`)
- **Purpose**: Identifies and tracks plastic and chemical contamination in ocean areas
- **Features**:
    - Report pollution incidents with GPS coordinates
    - Classify pollution types (plastic, chemical, oil, etc.)
    - Severity rating system (1-10 scale)
    - Verification mechanism for pollution reports
    - Reward system for accurate reporting

### 2. Cleanup Vessel Coordination Contract (`vessel-coordination.clar`)
- **Purpose**: Manages ocean cleaning ship operations and coordination
- **Features**:
    - Register cleanup vessels with capacity and capabilities
    - Assign vessels to pollution hotspots
    - Track vessel status and location
    - Coordinate multi-vessel operations
    - Performance tracking and ratings

### 3. Waste Processing Contract (`waste-processing.clar`)
- **Purpose**: Handles collected debris sorting and recycling operations
- **Features**:
    - Log collected waste by type and quantity
    - Track processing facilities and their capabilities
    - Manage recycling operations and outputs
    - Calculate recycling efficiency metrics
    - Distribute recycling rewards

### 4. Impact Measurement Contract (`impact-measurement.clar`)
- **Purpose**: Tracks cleanup effectiveness and ocean health metrics
- **Features**:
    - Monitor cleanup progress by region
    - Track ocean health improvements
    - Calculate environmental impact scores
    - Generate sustainability reports
    - Verify cleanup claims

### 5. Funding Distribution Contract (`funding-distribution.clar`)
- **Purpose**: Allocates resources to cleanup organizations and operations
- **Features**:
    - Manage funding pools from donors and sponsors
    - Distribute funds based on performance metrics
    - Track fund utilization and transparency
    - Reward high-performing cleanup operations
    - Handle emergency funding for critical areas

## Key Features

- **Decentralized Governance**: Community-driven decision making
- **Transparency**: All operations recorded on blockchain
- **Incentive Alignment**: Rewards for effective cleanup efforts
- **Global Coordination**: Worldwide cleanup effort coordination
- **Impact Verification**: Measurable environmental improvements
- **Sustainable Funding**: Continuous funding distribution model

## Data Structures

### Pollution Report
- Location coordinates (latitude, longitude)
- Pollution type and severity
- Reporter information
- Verification status
- Timestamp

### Cleanup Vessel
- Vessel ID and operator
- Capacity and capabilities
- Current location and status
- Performance metrics
- Assignment history

### Waste Processing Record
- Waste type and quantity
- Processing facility
- Recycling outputs
- Efficiency metrics
- Revenue generated

### Impact Metrics
- Region-specific cleanup progress
- Ocean health indicators
- Environmental improvement scores
- Verification proofs
- Timeline tracking

### Funding Allocation
- Funding source and amount
- Recipient organization
- Performance-based distribution
- Utilization tracking
- Impact correlation

## Getting Started

1. Install dependencies: `npm install`
2. Run tests: `npm test`
3. Deploy contracts using Clarinet
4. Initialize system with genesis data

## Testing

The system includes comprehensive tests covering:
- Contract functionality
- Integration between contracts
- Edge cases and error handling
- Performance scenarios
- Security validations

## Contributing

This is an open-source project aimed at solving ocean pollution through blockchain technology. Contributions are welcome!
