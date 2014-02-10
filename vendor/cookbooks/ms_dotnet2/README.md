# Microsoft .NET Framework 2.0 Cookbook

## Description

Installs Microsoft .NET Framework 2.0.

## Requirements

### Platforms

* Windows XP
* Windows Server 2003
* Windows Server 2003R2
* Windows Vista
* Windows Server 2008
* Windows Server 2008R2

Windows versions newer than Server 2008R2 do not need to use this cookbook.

### Cookbooks

* windows

# Attributes

These attributes are only applicable to Windows Server 2003R2, Server 2003, and XP. All other platforms will use Add/Remove Features.

* `node['ms_dotnet2']['url']` - The URL of the Microsoft .NET Framework 2.0 SP2 installer.
* `node['ms_dotnet2']['checksum']` - The checksum of the Microsoft .NET Framework 2.0 SP2 installer.

## Recipes

### default

Installs the .NET Framework 2.0 on applicable platforms, either using roles/features, or by downloading the executable from Microsoft directly.

License & Authors
-----------------

* Author:: Julian C. Dunn (<jdunn@getchef.com>)

```text

Copyright:: 2014, Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
