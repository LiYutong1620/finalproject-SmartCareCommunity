import request from "@/utils/request";

export function listUser(params) {
  return request({ url: "/system/user/list", method: "get", params });
}

export function addUser(data) {
  return request({ url: "/system/user", method: "post", data });
}

export function editUser(data) {
  return request({ url: "/system/user", method: "put", data });
}

export function deleteUser(userId) {
  return request({ url: `/system/user/${userId}`, method: "delete" });
}

export function changeUserStatus(data) {
  return request({ url: "/system/user/changeStatus", method: "put", data });
}

export function resetUserPwd(data) {
  return request({ url: "/system/user/resetPwd", method: "put", data });
}

export function listPermissions() {
  return request({ url: "/system/permission/list", method: "get" });
}

export function getUserPermissions(userId) {
  return request({ url: `/system/permission/user/${userId}`, method: "get" });
}

export function updateUserPermissions(userId, data) {
  return request({
    url: `/system/permission/user/${userId}`,
    method: "put",
    data,
  });
}

// --- 角色管理 ---
export function listRoles() {
  return request({ url: "/system/role/list", method: "get" });
}

export function addRole(data) {
  return request({ url: "/system/role", method: "post", data });
}

export function editRole(data) {
  return request({ url: "/system/role", method: "put", data });
}

export function deleteRole(roleId) {
  return request({ url: `/system/role/${roleId}`, method: "delete" });
}

export function getUserRoles(userId) {
  return request({ url: `/system/role/user/${userId}`, method: "get" });
}

export function assignUserRole(userId, data) {
  return request({ url: `/system/role/user/${userId}`, method: "put", data });
}

// --- 维修工技能标签 ---
export function listWorkerSkills(params) {
  return request({ url: "/system/worker-skill/list", method: "get", params });
}

export function addWorkerSkill(data) {
  return request({ url: "/system/worker-skill", method: "post", data });
}

export function editWorkerSkill(data) {
  return request({ url: "/system/worker-skill", method: "put", data });
}

export function deleteWorkerSkill(skillId) {
  return request({ url: `/system/worker-skill/${skillId}`, method: "delete" });
}

export function getSkillDict() {
  return request({ url: "/system/worker-skill/dict", method: "get" });
}
