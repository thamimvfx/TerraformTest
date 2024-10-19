# TerraformTest
ClearBank Test

Time spent - rouhgly 2-3 hours.

I have created terraform templates using the online documentation found on terraform registry. 

The backup strategy I implemented was a recovery services vault this was created to store and manage backups of virtual machines and a backup policy was created to define how often the backups are taken and retained for.
each vm is configured as a protected VM by assosicating it witht he backup policy.

Lifecycle implementation =
to avoid uninteded data loss or disruptions during updates, the lifecycle blokc was added into the virtual machine resource "create_before_destroy" this is to ensure replacement resources are created before the existing resources are destroyed.