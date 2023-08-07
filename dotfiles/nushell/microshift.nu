
def "o" [cmd?: string] {
  if $cmd == null {
    sshk ostree-dev
  } else {
    print $"ssh ostree-dev ($cmd)"
    ssh ostree-dev $cmd
  }
}

def "o status rpm-ostree" [] {
  o "sudo rpm-ostree status -v"
}

def "o status ostree" [] {
  o "sudo ostree admin status -v"
}

def "o reinstall" [] {
    try { sudo virsh destroy ostree-dev }
    try { sudo virsh undefine ostree-dev --remove-all-storage }
    sudo virt-install --name "ostree-dev" --vcpus 4 --memory 8192 --disk "path=/var/lib/libvirt/images/ostree-dev.qcow2,size=40" --network network=default,mac=52:54:00:9c:e5:99,model=virtio --events on_reboot=restart --location /var/lib/libvirt/images/rhel-9.2-x86_64-boot.iso --extra-args "inst.ks=http://192.168.124.5:8080/kickstart.ks" --autoconsole graphical
    ssh-keygen -R 192.168.124.6
}

def "o console" [] {
    sudo virsh console ostree-dev
}

def "o grub-envs" [] {
  o "sudo grub2-editenv -- list"
}

def "o watch-start-up" [] {
  sshk ostree-dev 'mkdir -p ~/.kube && sudo cat /var/lib/microshift/resources/kubeadmin/kubeconfig > ~/.kube/config'
  sshk ostree-dev 'watch -n0.1 "oc get pods -A; echo; sudo crictl ps; echo; sudo journalctl -n 10 -xu microshift"'
}

def svcs [] { [ 
  "microshift", "microshift-test-agent",
  "greenboot-healthcheck", "greenboot-task-runner", "redboot-task-runner" 
] }
def "o journal" [unit: string@svcs, boot?: int, --follow=false, --n=30: int] {
  mut nn  = $n;
  let f = if $follow { "-f" } else { "" }
  let b = if $boot != null { $nn = 300; $"-b($boot)";  } else { "" }

  o $"sudo journalctl -n($nn) ($f) ($b) -u ($unit)"
}

def "o systemctl" [verb: string, unit: string@svcs] {
  o $"sudo systemctl ($verb) ($unit)"
}

def "o boots" [] { o "sudo journalctl --list-boots --reverse" }

def refs [] {[ 
  "edge:rhel/9/x86_64/edge", 
  "edge:microshift/4.13", 
  "edge:microshift/source",
  "ostree-unverified-registry:registry.pmatuszak.com/microshift:latest",
  "ostree-unverified-registry:registry.pmatuszak.com/microshift:fake-415"
]}

def "o restore" [ref: string@refs] {
  ~/dev/ushift-extras/restore-ostree-dev.sh $ref
}

def "o rebase" [ref: string@refs] {
  o $"sudo rpm-ostree rebase ($ref)"
}

def "o reboot" [] {
  o "sudo systemctl reboot"
}

#def "o rebuild commit" [] {
  #sshk dev "/mnt/host/dev/source-commit.sh"
#}

def "o rebuild oci" [file: string] { sshk dev $"/mnt/host/dev/ushift-extras/oci/($file).sh" }
def "o rebuild oci base" [] { o rebuild oci "base" }
def "o rebuild oci latest" [] { o rebuild oci "latest" }
def "o rebuild oci fake-415" [] { o rebuild oci "fake-4.15" }


def "o konfig" [] {
  o "mkdir -p ~/.kube && sudo cat /var/lib/microshift/resources/kubeadmin/kubeconfig > ~/.kube/config"
}

def "o pods" [--watch] {
  o konfig
  if watch != null {
    ssh ostree-dev -t "watch -n0.1 oc get pods -A"
  } else {
    o "oc get pods -A"
  }
}

let DATA_DIR = "/var/lib/microshift"
let VERSION_FILE = $"($DATA_DIR)/version"

let BACKUP_DIR = "/var/lib/microshift-backups"
let HEALTH_FILE = $"($BACKUP_DIR)/health.json"

def "o data ls" [] { o $"sudo ls ($DATA_DIR)" }
def "o data rm" [] { o $"sudo rm -rf ($DATA_DIR)" }
def "o data cd" [] { ssh ostree-dev -t $"sudo -s bash -c 'cd ($DATA_DIR) && bash'" }

def "o backups ls" [] { o $"sudo ls -lah ($BACKUP_DIR)" }
def "o backups rm" [] { o $"sudo rm -rf ($BACKUP_DIR)" }
def "o backups cd" [] { ssh ostree-dev -t $"sudo -s bash -c 'cd ($BACKUP_DIR) && bash'" }

def "o version cat" [] { o $"sudo cat ($VERSION_FILE)" }
def "o version rm" [] { o $"sudo rm ($VERSION_FILE)" }
def "o version edit" [] { ssh ostree-dev -t $"sudo vi ($VERSION_FILE)" }

def "o health cat" [] { o $"sudo cat ($HEALTH_FILE)" }
def "o health rm" [] { o $"sudo rm ($HEALTH_FILE)" }
def "o health edit" [] { ssh ostree-dev -t $"sudo vi ($HEALTH_FILE)" }



def files   [] { ls -s ~/microshift/test/scenarios/  | get name }
def actions [] { [ "create", "cleanup", "run", "rerun", "edit" ] }

def scenario [file: string@files, action: string@actions] {
  cd ~/microshift/test/
  let fullpath =  $"./scenarios/($file)"
  if $action == "edit" {
    hx $fullpath
    return
  }

  SSH_PRIVATE_KEY="/home/pm/.ssh/id_rsa" ./bin/scenario.sh $action $fullpath
}

def checkout-pr [ref: string, repo: string = "microshift"] {
  cd ~/microshift
  let sref = ($ref | split column ':' | rename org branch)
  let org = ($sref.org | to text)
  let branch = ($sref.branch | to text)
  git fetch $"https://github.com/($org)/($repo).git" $"($branch):($org)/($branch)"
  git switch $"($org)/($branch)"
  #copejon:USHIFT-1096
  #git fetch https://github.com/ggiguash/microshift.git mask_grub_timer:ggiguash/mask_grub_timer
}
