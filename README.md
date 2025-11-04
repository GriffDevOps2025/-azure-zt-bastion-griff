# Azure Zero-Trust Bastion Architecture

![Terraform](https://img.shields.io/badge/Terraform-v1.12.2-623CE4?logo=terraform)
![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoftazure)
![License](https://img.shields.io/badge/License-MIT-green)

Production-grade Infrastructure as Code implementation of zero-trust network architecture on Microsoft Azure. Demonstrates enterprise security patterns with identity-enforced access, network micro-segmentation, and complete elimination of public attack surface.

---

## 🎯 Architecture Overview

**Zero-trust implementation featuring:**
- Private-only VM infrastructure (no public IPs)
- Azure Bastion PaaS for secure remote access
- Deny-all-by-default NSG policies with explicit Bastion subnet allowlist
- Azure AD authentication with MFA enforcement
- Full infrastructure lifecycle managed via Terraform

**Design Pattern:** Secure jump host architecture leveraging Azure managed services to eliminate operational overhead of traditional bastion hosts (patching, monitoring, vulnerability management).

---

## 🏗️ Network Topology
```
┌─────────────────────────────────────────────────────┐
│                   Azure Cloud                        │
│  ┌────────────────────────────────────────────────┐ │
│  │   Virtual Network (10.0.0.0/16)                │ │
│  │                                                 │ │
│  │   ┌──────────────────┐   ┌─────────────────┐  │ │
│  │   │ AzureBastionSubnet│   │ Private Subnet  │  │ │
│  │   │   (10.0.1.0/26)   │   │  (10.0.2.0/24)  │  │ │
│  │   │                   │   │                 │  │ │
│  │   │  ┌─────────────┐  │   │  ┌───────────┐ │  │ │
│  │   │  │   Bastion   │  │   │  │    VM     │ │  │ │
│  │   │  │   Host      │──┼───┼─▶│ (Private) │ │  │ │
│  │   │  │ (Public IP) │  │   │  │ (No Pub IP)│ │  │ │
│  │   │  └─────────────┘  │   │  └───────────┘ │  │ │
│  │   └──────────────────┘   └─────────────────┘  │ │
│  │                                                 │ │
│  │   ┌──────────────────────────────────────┐    │ │
│  │   │  Network Security Group (NSG)        │    │ │
│  │   │  • Allow: Bastion → VM (SSH/22)      │    │ │
│  │   │  • Deny: All other inbound traffic   │    │ │
│  │   └──────────────────────────────────────┘    │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  Access Path: Azure AD → Portal → Bastion → VM     │
└─────────────────────────────────────────────────────┘
```

### Security Controls

| Layer | Control | Enforcement |
|-------|---------|-------------|
| **Identity** | Azure AD + MFA | Portal authentication required |
| **Network** | No public IPs | VM unreachable from internet |
| **Perimeter** | NSG deny-all default | Only Bastion subnet whitelisted |
| **Application** | Bastion-only access | No SSH port 22 exposure |

---



## 🚀 Deployment

### Prerequisites

- Azure subscription with Owner/Contributor access
- Azure CLI >= 2.50.0
- Terraform >= 1.5.0
- SSH key pair for VM authentication

### Implementation
```powershell
# Repository setup
git clone https://github.com/YOUR_USERNAME/azure-zt-bastion-griff.git
cd azure-zt-bastion-griff

# Generate authentication keys
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_bastion_key

# Azure authentication
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Infrastructure deployment
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

**Deployment duration:** 12-15 minutes (Bastion host provisioning: 8-10 min)

---

## 📁 Infrastructure Code Structure
```
azure-zt-bastion-griff/
├── providers.tf           # AzureRM provider v3.85.0
├── variables.tf           # Parameterized inputs
├── terraform.tfvars       # Environment-specific values
├── main.tf                # Resource group and metadata
├── networking.tf          # VNet, subnets, CIDR allocation
├── nsg.tf                 # Security group rules and associations
├── bastion.tf             # Azure Bastion (Basic SKU)
├── vm.tf                  # Ubuntu 22.04 LTS VM (private)
├── outputs.tf             # Resource IDs and connection strings
└── README.md              # Technical documentation
```

---

## 🔒 Security Implementation

### Network Segmentation

**Bastion Subnet (10.0.1.0/26):**
- Required /26 minimum for Azure Bastion
- Dedicated subnet per Azure requirements
- Egress-only for Bastion service

**Private Subnet (10.0.2.0/24):**
- Workload VMs with no public IPs
- NSG enforces Bastion-only ingress
- Internet egress via Azure default route

### NSG Rule Set
```hcl
# Inbound
Priority 100:  Allow TCP/22 from 10.0.1.0/26 → Any
Priority 4096: Deny * from Any → Any

# Outbound
Priority 100:  Allow * from Any → Internet
```

### Compliance Verification
```powershell
# Validate no public IP assignment
az vm list-ip-addresses \
  --resource-group rg-ztb-griff \
  --name ztb-griff-vm \
  --query "[].virtualMachine.network.publicIpAddresses" \
  --output table
# Expected: Empty

# Audit NSG rules
az network nsg rule list \
  --resource-group rg-ztb-griff \
  --nsg-name ztb-griff-private-nsg \
  --output table
```

---

## 💰 Cost Analysis

### Resource Pricing (US East)

| Resource | SKU | $/Hour | $/Day | $/Month |
|----------|-----|--------|-------|---------|
| Azure Bastion | Basic | $0.10 | $2.40 | $73.00 |
| Linux VM | Standard_B1s | $0.01 | $0.24 | $7.59 |
| Managed Disk | Standard LRS 30GB | — | $0.06 | $1.92 |
| Public IP | Standard Static | — | $0.08 | $2.40 |
| VNet/NSG | — | Free | Free | Free |
| **TOTAL** | | **$0.11** | **$2.78** | **$84.91** |

### Cost Optimization Strategies

- Bastion Basic SKU reduces cost 50% vs Standard
- B-series burstable VMs for non-production workloads
- Standard LRS storage for non-critical data
- Hub-spoke topology for Bastion sharing across multiple VNets (production)

### Resource Cleanup
```powershell
# Complete infrastructure teardown
terraform destroy -auto-approve

# Verification
az group show --name rg-ztb-griff 2>&1 | Select-String "ResourceGroupNotFound"
az resource list --query "[?contains(name,'ztb')]" --output table
```

---

## 🛠️ Technical Notes

### Azure Provider Registration

If deploying with service principal, ensure providers are pre-registered:
```powershell
az provider register --namespace Microsoft.Network --wait
az provider register --namespace Microsoft.Compute --wait
az provider register --namespace Microsoft.Storage --wait
```

### Regional Capacity Planning

VM SKU availability varies by region. If encountering `SkuNotAvailable`:
```hcl
# terraform.tfvars
location = "westus2"  # or centralus, northeurope
vm_size  = "Standard_D2s_v3"  # broader availability
```

### Network Connectivity for Terraform

Azure management API calls require:
- Egress to `management.azure.com:443`
- No TLS inspection/MITM proxies
- DNS resolution for `*.azure.com`

If corporate network blocks Azure APIs, use:
```hcl
# providers.tf - add if needed
provider "azurerm" {
  skip_provider_registration = true
  subscription_id = var.subscription_id
  # ... other config
}
```

---

## 📊 Technical Specifications

**Terraform Configuration:**
- Provider: `hashicorp/azurerm` v3.85.0
- State: Local (migrate to Azure Storage for production)
- Variables: Parameterized for multi-environment deployment

**Azure Resources:**
- Region: US East (configurable)
- Resource Group: Single RG with consistent tagging
- Network: RFC1918 private addressing (10.0.0.0/16)
- Compute: Ubuntu 22.04 LTS (Canonical)
- Security: Managed identities ready (not implemented in demo)

**Access Pattern:**
- Authentication: Azure AD (MFA enforced at tenant level)
- Authorization: RBAC (Virtual Machine Contributor minimum)
- Connection: Browser-based SSH via Bastion portal integration
- Auditing: Azure Activity Log (session logging requires Log Analytics)

---

## 📄 License

MIT License - See LICENSE file

---

## 👤 Contact

**Griff** - Cloud Security & Infrastructure Specialist

- GitHub: [@your-username](https://github.com/your-username)
- LinkedIn: [your-profile](https://linkedin.com/in/yourprofile)
- Email: your.email@example.com

---

## 📚 References

- [Azure Bastion Documentation](https://docs.microsoft.com/azure/bastion/)
- [NIST 800-207: Zero Trust Architecture](https://csrc.nist.gov/publications/detail/sp/800-207/final)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [CIS Azure Foundations Benchmark](https://www.cisecurity.org/benchmark/azure)

---

**Implementation Status:** Production-ready architecture pattern  
**Use Case:** Secure administrative access, compliance-driven environments, zero-trust network segmentation

*Enterprise-grade cloud security architecture*
