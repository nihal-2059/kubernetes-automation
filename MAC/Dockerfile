FROM redhat/ubi8
RUN  yum install -y yum-utils && yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo && yum -y install terraform
RUN  yum install python3 -y && pip3 install --upgrade pip && pip3 install ansible
CMD  ["/bin/bash"]
