# GCP Snapshot Management

A PowerShell automation script for managing Google Cloud Platform (GCP) disk snapshots with intelligent retention policies.

## Overview

This repository contains a PowerShell script that automates the creation and management of disk snapshots in Google Cloud Platform. The script creates snapshots of all disks in specified zones and automatically maintains a rolling backup window by deleting the oldest snapshots when the total count exceeds 8 snapshots.

## Features

- **Automated Snapshot Creation**: Creates snapshots for all disks in specified GCP zones
- **Smart Retention Policy**: Maintains a maximum of 8 snapshots, automatically deleting the oldest when a 9th snapshot is created
- **Elevated Privileges**: Automatically requests administrator privileges when executed
- **Comprehensive Logging**: All operations are logged to a transcript file with timestamps
- **Error Handling**: Includes retry logic for snapshot deletion operations
- **Progress Reporting**: Displays snapshot counts before and after operations

## Prerequisites

- **Windows PowerShell** (Administrator rights required)
- **Google Cloud SDK** installed and configured
- **gcloud CLI** tools available in PATH
- **PowerShell Google Cloud Module** (`Get-GceDisk`, `Add-GceSnapshot`, `Get-GceSnapshot`, `Remove-GceSnapshot`)
- Active GCP project with compute engine permissions

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/enricagra/GCP.git
   ```

2. Ensure you have the Google Cloud PowerShell module installed:
   ```powershell
   Install-Module GoogleCloud
   ```

## Configuration

Before running the script, update the following variables in `GCP Snapshot with Conditions.ps1`:

```powershell
$Project = "evident-ocean-315608"      # Your GCP project ID
$Zones = "asia-northeast1-b"           # Comma-separated zones
$LogPath = "C:\gcp-logs\"              # Log output directory
```

## Usage

1. Open PowerShell as Administrator
2. Navigate to the repository directory
3. Run the script:
   ```powershell
   .\GCP Snapshot with Conditions.ps1
   ```

The script will:
1. Verify administrator privileges (auto-elevate if needed)
2. Authenticate with GCP
3. Create snapshots for all disks in specified zones
4. Check total snapshot count
5. Delete the oldest snapshot if count exceeds 8
6. Log all operations to a timestamped transcript file
7. Display final snapshot count

## How It Works

### Snapshot Creation
The script iterates through all specified zones and creates snapshots for every disk found using `Add-GceSnapshot`.

### Retention Logic
When the total number of snapshots exceeds 8:
- Identifies the oldest snapshot by creation time
- Attempts deletion with retry logic (up to 2 attempts)
- Exits with error code 4 if deletion fails twice
- Repeats until exactly 8 snapshots remain

### Logging
All operations are recorded to:
```
C:\gcp-logs\<ISO-8601-Timestamp>.txt
```

## Exit Codes

- **0**: Successful execution
- **4**: Abnormal termination - snapshot deletion failed twice

## Security Notes

⚠️ **Important**: The script currently contains a hardcoded email address for GCP authentication. For production use:
- Remove or parameterize the hardcoded email
- Use service account authentication when possible
- Never commit credentials to version control
- Consider using GCP Application Default Credentials (ADC)

## Scheduling

To run this script automatically, use Windows Task Scheduler:
1. Create a new scheduled task
2. Set the action to run: `powershell.exe -File "C:\path\to\GCP Snapshot with Conditions.ps1"`
3. Configure the schedule (daily, weekly, etc.)
4. Ensure the task runs under an account with GCP permissions

## Troubleshooting

**Issue**: Script fails to elevate privileges
- Ensure you have administrator rights on the system

**Issue**: GCP authentication fails
- Verify gcloud is installed and in your PATH
- Run `gcloud auth login` manually first

**Issue**: Snapshot operations timeout
- Check your GCP quota limits
- Verify network connectivity to GCP

**Issue**: Log file not created
- Ensure `C:\gcp-logs\` directory exists and is writable
- Create the directory manually if needed

## Contributing

Feel free to submit issues and enhancement requests!

## License

[Specify your license here]

## Contact

For questions or issues, please open an issue on GitHub or contact enricagra.