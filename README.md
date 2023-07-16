# cbdynvagrant

cbdynvagrant is a vagrant file that provisions a virtual machine in virtualbox or hyperv
which is configured to enable use of docker macvlan networking on host systems which are
unable to provide this functionality out of the box (i.e. Windows and Mac).

This vagrant is specifically designed for use with cbdyncluster and will provision a
docker host at `192.168.99.5` and enable the provisoning of docker containers using the
`macvlan0` network which will place them in the `192.168.99.128 - 192.168.99.255` range.

## Important Notes

- Access to the docker host and running containers is only possible from the host
  system which executes the vagrant.
- On Windows, due to VirtualBox limitations, you must enable the windows HyperV feature
  if WSL2 is in use. Vagrant will then use HyperV for provision instead. You must be
  using Windows Pro for the Hyper-V features to be available.
