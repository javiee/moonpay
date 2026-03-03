
#!/bin/sh

K8_CLUSTER="moonpay-cluster"
KIND_CLUSTER_VERSION="v0.31.0"
HELM_VERSION="v3.16.4"

installKind(){
    if ! command kind 2>&1 >/dev/null
    then
        echo "Installing kind"
        case "$(uname -m)" in
            x86_64)  KIND_ARCH="amd64" ;;
            aarch64|arm64) KIND_ARCH="arm64" ;;
            *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
        esac
        curl -Lo ./kind "https://kind.sigs.k8s.io/dl/${KIND_CLUSTER_VERSION}/kind-linux-${KIND_ARCH}"
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind
    fi
}

installKubectl() {

    if ! command kubectl 2>&1 >/dev/null
    then
        echo "installing kubectl"
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin/kubectl
    fi

}

installHelm() {
    if ! command helm 2>&1 >/dev/null
    then
        echo "installing helm"
        case "$(uname -m)" in
            x86_64)  HELM_ARCH="amd64" ;;
            aarch64|arm64) HELM_ARCH="arm64" ;;
            *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
        esac
        curl -LO "https://get.helm.sh/helm-${HELM_VERSION}-linux-${HELM_ARCH}.tar.gz"
        tar -xvf "helm-${HELM_VERSION}-linux-${HELM_ARCH}.tar.gz"
        chmod +x "linux-${HELM_ARCH}/helm"
        mv "linux-${HELM_ARCH}/helm" /usr/local/bin/helm
        rm -rf "linux-${HELM_ARCH}/" helm-*
    fi

}


installKubectl
installHelm
installKind

if sudo kind get clusters | grep -q "^${K8_CLUSTER}$"; then
    echo "Cluster '${K8_CLUSTER}' exists"
    kubectl cluster-info --context kind-${K8_CLUSTER}
        
else
    echo "Cluster ${K8_CLUSTER} does not exist, creating!"
    kind create cluster --name ${K8_CLUSTER}
    sudo kind get kubeconfig --name ${K8_CLUSTER} >> $HOME/.kube/config
    kubectl cluster-info --context kind-${K8_CLUSTER}
fi