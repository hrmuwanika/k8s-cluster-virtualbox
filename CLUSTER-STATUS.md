# Sample Cluster - Successfully Deployed! 🎉

## Cluster Details

**Type:** Kubernetes in Docker (kind)
**Nodes:** 3 (1 control-plane + 2 workers)
**Application:** Node.js REST API (3 replicas)
**Status:** ✅ Running

## Cluster Information

### Nodes
```
NAME                         STATUS   ROLES           VERSION
k8s-node-api-control-plane   Ready    control-plane   v1.27.3
k8s-node-api-worker          Ready    <none>          v1.27.3
k8s-node-api-worker2         Ready    <none>          v1.27.3
```

### Application Pods
```
NAME                        READY   STATUS    NODE
node-api-66d7ff7b46-5k55x   1/1     Running   k8s-node-api-worker2
node-api-66d7ff7b46-bknv8   1/1     Running   k8s-node-api-worker
node-api-66d7ff7b46-fdpbm   1/1     Running   k8s-node-api-worker2
```

**Load balanced across 2 worker nodes** ✅

## Access the API

**URL:** http://localhost:30080

### Quick Tests

```bash
# Get API info
curl http://localhost:30080

# Check health
curl http://localhost:30080/health

# Get all items
curl http://localhost:30080/api/items

# Create an item
curl -X POST http://localhost:30080/api/items \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test Item","description":"My first item"}'

# Get specific item (use ID from create response)
curl http://localhost:30080/api/items/{id}

# Update item
curl -X PUT http://localhost:30080/api/items/{id} \
  -H 'Content-Type: application/json' \
  -d '{"name":"Updated Item"}'

# Delete item
curl -X DELETE http://localhost:30080/api/items/{id}
```

## Monitoring Commands

```bash
# View all resources
kubectl get all -n node-api

# View pod logs
kubectl logs -n node-api -l app=node-api --tail=50

# Follow logs from all pods
kubectl logs -n node-api -l app=node-api -f

# Shell into a pod
kubectl exec -it -n node-api node-api-66d7ff7b46-5k55x -- sh

# Watch pods
kubectl get pods -n node-api -w

# Describe service
kubectl describe svc -n node-api node-api
```

## Verified Features

✅ Multi-node cluster (3 nodes)
✅ Application deployed (3 replicas)
✅ Load balancing across workers
✅ REST API fully functional
✅ Health checks working
✅ CRUD operations working
✅ Each pod shows unique hostname (load balancing proof)

## Cleanup

When you're done testing:

```bash
kind delete cluster --name k8s-node-api
```

## Notes

- Data is stored in-memory (not persisted)
- Each API response includes the hostname showing which pod handled the request
- Demonstrates load balancing across multiple pods
- Perfect for development and testing

---

**Deployment completed:** January 11, 2026
**Setup time:** ~1 minute
**Method:** kind (Kubernetes in Docker)
