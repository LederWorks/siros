# Call Graph Generation Status

## Current Status

✅ **Optimized**: Call graph generation system streamlined to focus on the most effective visualizations.

### Primary Visualization

**full-comprehensive.svg** (53KB) - ✅ Working - **Primary Overview**

- Complete call graph with enhanced depth parameters
- Shows deeper function call relationships and internal interactions
- Includes database connections, context handling, and service layer details
- Configured with optimal grouping (`pkg,type`) and layout parameters
- **Best visualization** for understanding Siros backend architecture

### Component-Specific Visualizations

✅ **Working Component Graphs**:

- **api-layer.svg** (24KB) - Shows API handlers and routing
- **services-layer.svg** (61KB) - Shows service layer interactions (largest graph)
- **storage-layer.svg** (13KB) - Shows storage and configuration components

### Known Issues

❌ **providers-layer.svg**: Disabled due to unused package

- The providers package exists but is not imported/used in main execution path
- go-callvis cannot analyze unused packages with focus parameter
- Will work once providers are integrated into main application flow

## Current File Structure

| File | Size | Status | Content |
|------|------|--------|---------|
| **full-comprehensive.svg** | 53KB | ✅ Primary | Complete backend with enhanced depth and dependencies |
| api-layer.svg | 24KB | ✅ Working | API handlers and routing |
| services-layer.svg | 61KB | ✅ Working | Service layer interactions (largest component) |
| storage-layer.svg | 13KB | ✅ Working | Storage and configuration components |
| config-layer.svg | 9KB | ✅ Working | Configuration layer call graph |
| middleware.svg | 21KB | ✅ Working | Middleware call graph |

**Removed redundant visualizations:**

- ❌ `main-overview.svg` - Redundant with full-comprehensive
- ❌ `full-backend.svg` - Redundant with full-comprehensive
- ❌ `ultra-deep.svg` - Not actually deep, redundant

## Script Status

✅ **scripts/generate-callgraph.ps1**: Fully functional and optimized

- Generates the comprehensive overview plus component-specific views
- Runs cleanly without errors
- Produces meaningful visualizations with appropriate file sizes
- Removes redundant and ineffective graph types
