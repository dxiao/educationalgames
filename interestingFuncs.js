// findSize
//(091)
function findTreeSize(node) {
  var size = 0;
  if (node.value) {
    size++;
  }
  if (node.left) {
    size += findTreeSize(node.left);
  }
  if (node.right) {
    size += findTreeSIze(node.right);
  }
  return size;
}

//(550)
function findSize(t) {
  if (!t) {
    return 0;
  }
  else {
    return 1 + findSize(t.left) + findSize(t.right);
  }
}

//(224)
function findSize(myTreeNode) {
  if myTreeNode.left={}:
    return 0
  elseif myTreeNode.right=={}:
    return 0
  else:
    return 1 + findSize(myTreeNode.left)+findSize(myTreeNode.right)
}

//insert 

//(091)
// Assumes that indeces are unique
function insertNodeInTree(node, element, index) {
  if (node.value == undefined) {
    node.index = index
    node.value = value
    return
  } else if (node.index < index) {
    if (node.left) {
      return insertNodeInTree(node.left, element, index)
    } else {
      node.left = new TreeNode(index, element, null, null)
    }
  } else {
    if (node.right) {
      return insertNodeInTree(node.right, element, index)
    } else {
      node.right = new TreeNode(index, element, null, null)
    }
  }
}

//(170)
// root: a TreeNode representing the root of a binary tree in which to insert the element
// node: a TreeNode to be inserted into root
insert = function(root, node) {
  if (node.value >= root.value) {
    if (root.right != null) {
      insert(root.right, node)
    } else {
      root.right = node
  } else {
    if (root.left != null) {
      insert(root.left, node)
    } else {
      root.left = node
    }
  }
}
