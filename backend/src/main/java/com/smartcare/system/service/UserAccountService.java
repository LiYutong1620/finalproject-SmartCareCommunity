package com.smartcare.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.property.domain.CmBuilding;
import com.smartcare.business.property.domain.CmHouse;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmBuildingMapper;
import com.smartcare.business.property.mapper.CmHouseMapper;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.business.repair.domain.RpWorkerProfile;
import com.smartcare.business.repair.mapper.RpWorkerProfileMapper;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.domain.*;
import com.smartcare.system.mapper.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * 三端账号分表：业主 / 维修工 / 物业，统一组装为 {@link SysUser} 供现有业务使用。
 */
@Service
@RequiredArgsConstructor
public class UserAccountService {

    private final SysOwnerAccountMapper ownerAccountMapper;
    private final SysWorkerAccountMapper workerAccountMapper;
    private final SysPropertyAccountMapper propertyAccountMapper;
    private final CmResidentMapper residentMapper;
    private final CmHouseMapper houseMapper;
    private final CmBuildingMapper buildingMapper;
    private final RpWorkerProfileMapper workerProfileMapper;
    private final PmStaffMapper staffMapper;

    public SysUser findByUsername(String username) {
        if (!StringUtils.hasText(username)) {
            return null;
        }
        SysUser owner = loadOwnerByUsername(username.trim());
        if (owner != null) return owner;
        SysUser worker = loadWorkerByUsername(username.trim());
        if (worker != null) return worker;
        return loadPropertyByUsername(username.trim());
    }

    public SysUser findById(Long userId) {
        if (userId == null) return null;
        SysUser owner = loadOwnerById(userId);
        if (owner != null) return owner;
        SysUser worker = loadWorkerById(userId);
        if (worker != null) return worker;
        return loadPropertyById(userId);
    }

    public SysUser findById(Long userId, String userType) {
        if (userId == null) return null;
        return switch (normalizeType(userType)) {
            case "0" -> loadOwnerById(userId);
            case "1" -> loadWorkerById(userId);
            case "2" -> loadPropertyById(userId);
            default -> findById(userId);
        };
    }

    public Page<SysUser> pageList(int pageNum, int pageSize, String username, String nickName, String userType) {
        List<SysUser> all = new ArrayList<>();
        if (!StringUtils.hasText(userType) || "0".equals(userType)) {
            all.addAll(listOwners(username));
        }
        if (!StringUtils.hasText(userType) || "1".equals(userType)) {
            all.addAll(listWorkers(username));
        }
        if (!StringUtils.hasText(userType) || "2".equals(userType)) {
            all.addAll(listPropertyUsers(username));
        }
        all = all.stream().filter(u -> matchesUserQuery(u, username, nickName)).toList();
        all = new ArrayList<>(all);
        all.sort(Comparator.comparing(SysUser::getUserId));
        long total = all.size();
        int from = Math.max(0, (pageNum - 1) * pageSize);
        int to = Math.min(all.size(), from + pageSize);
        List<SysUser> page = from >= all.size() ? List.of() : all.subList(from, to);
        Page<SysUser> result = new Page<>(pageNum, pageSize, total);
        result.setRecords(page);
        return result;
    }

    @Transactional
    public Long registerOwner(SysUser user) {
        assertUsernameAvailable(user.getUsername());
        if (StringUtils.hasText(user.getPhone())) {
            assertPhoneAvailable(user.getPhone().trim(), null, "0");
        }
        SysOwnerAccount acc = new SysOwnerAccount();
        acc.setUsername(user.getUsername());
        acc.setPassword(user.getPassword());
        acc.setStatus("0");
        acc.setDelFlag("0");
        if (StringUtils.hasText(user.getNickName())) {
            acc.setBindName(user.getNickName().trim());
        }
        if (StringUtils.hasText(user.getPhone())) {
            acc.setBindPhone(user.getPhone().trim());
        }
        ownerAccountMapper.insert(acc);
        return acc.getAccountId();
    }

    @Transactional
    public Long createUser(SysUser user) {
        assertUsernameAvailable(user.getUsername());
        String type = normalizeType(user.getUserType());
        return switch (type) {
            case "1" -> createWorker(user);
            case "2" -> createProperty(user);
            default -> createOwnerWithResident(user);
        };
    }

    @Transactional
    public void updateProfile(SysUser user) {
        if (user.getUserId() == null) return;
        SysUser db = findById(user.getUserId());
        if (db == null) throw new ServiceException("用户不存在");
        switch (normalizeType(db.getUserType())) {
            case "0" -> updateOwnerAccount(user, db);
            case "1" -> updateWorkerAccount(user, db);
            case "2" -> updatePropertyAccount(user, db);
            default -> throw new ServiceException("未知用户类型");
        }
    }

    public void updatePassword(Long userId, String encodedPassword) {
        SysUser db = findById(userId);
        if (db == null) throw new ServiceException("用户不存在");
        switch (normalizeType(db.getUserType())) {
            case "0" -> {
                SysOwnerAccount u = new SysOwnerAccount();
                u.setAccountId(userId);
                u.setPassword(encodedPassword);
                ownerAccountMapper.updateById(u);
            }
            case "1" -> {
                SysWorkerAccount u = new SysWorkerAccount();
                u.setAccountId(userId);
                u.setPassword(encodedPassword);
                workerAccountMapper.updateById(u);
            }
            case "2" -> {
                SysPropertyAccount u = new SysPropertyAccount();
                u.setAccountId(userId);
                u.setPassword(encodedPassword);
                propertyAccountMapper.updateById(u);
            }
            default -> throw new ServiceException("未知用户类型");
        }
    }

    @Transactional
    public void deleteUser(Long userId) {
        SysUser db = findById(userId);
        if (db == null) return;
        switch (normalizeType(db.getUserType())) {
            case "0" -> ownerAccountMapper.deleteById(userId);
            case "1" -> workerAccountMapper.deleteById(userId);
            case "2" -> propertyAccountMapper.deleteById(userId);
            default -> { }
        }
    }

    public boolean isPhoneUsed(String phone, Long excludeUserId, String userType) {
        if (!StringUtils.hasText(phone)) return false;
        return !assertPhoneAvailableQuiet(phone, excludeUserId, userType);
    }

    private Long createOwnerWithResident(SysUser user) {
        assertPhoneAvailable(user.getPhone(), null, "0");
        SysOwnerAccount acc = new SysOwnerAccount();
        acc.setUsername(user.getUsername());
        acc.setPassword(user.getPassword());
        acc.setStatus(StringUtils.hasText(user.getStatus()) ? user.getStatus() : "0");
        acc.setDelFlag("0");
        if (StringUtils.hasText(user.getNickName())) {
            acc.setBindName(user.getNickName().trim());
        }
        if (StringUtils.hasText(user.getPhone())) {
            acc.setBindPhone(user.getPhone().trim());
        }
        if (user.getProfileRefId() != null) {
            acc.setResidentId(user.getProfileRefId());
        }
        ownerAccountMapper.insert(acc);

        if (acc.getResidentId() == null && user.getHouseId() != null) {
            CmResident resident = residentMapper.selectOne(new LambdaQueryWrapper<CmResident>()
                .eq(CmResident::getHouseId, user.getHouseId())
                .eq(CmResident::getDelFlag, "0")
                .last("LIMIT 1"));
            if (resident != null) {
                CmResident link = new CmResident();
                link.setResidentId(resident.getResidentId());
                link.setUserId(acc.getAccountId());
                residentMapper.updateById(link);
                acc.setResidentId(resident.getResidentId());
                ownerAccountMapper.updateById(acc);
            }
        }
        return acc.getAccountId();
    }

    private Long createWorker(SysUser user) {
        assertPhoneAvailable(user.getPhone(), null, "1");
        SysWorkerAccount acc = new SysWorkerAccount();
        acc.setUsername(user.getUsername());
        acc.setPassword(user.getPassword());
        acc.setStatus(StringUtils.hasText(user.getStatus()) ? user.getStatus() : "0");
        acc.setDelFlag("0");
        workerAccountMapper.insert(acc);

        RpWorkerProfile profile = new RpWorkerProfile();
        profile.setWorkerId(acc.getAccountId());
        profile.setRealName(StringUtils.hasText(user.getNickName()) ? user.getNickName() : user.getUsername());
        profile.setPhone(user.getPhone());
        profile.setGender(user.getGender());
        profile.setAge(user.getAge());
        profile.setAvatar(user.getAvatar());
        profile.setWorkStatus("available");
        profile.setWorkerLevel("初级");
        profile.setCertAuditStatus("1");
        profile.setAvgScore(new java.math.BigDecimal("5.00"));
        profile.setEvalCount(0);
        workerProfileMapper.insert(profile);
        return acc.getAccountId();
    }

    private Long createProperty(SysUser user) {
        assertPhoneAvailable(user.getPhone(), null, "2");
        PmStaff staff = new PmStaff();
        staff.setName(StringUtils.hasText(user.getNickName()) ? user.getNickName() : user.getUsername());
        staff.setPhone(user.getPhone());
        staff.setGender(user.getGender());
        staff.setAge(user.getAge());
        staff.setAvatar(user.getAvatar());
        staff.setDept("物业管理部");
        staff.setDelFlag("0");
        staffMapper.insert(staff);

        SysPropertyAccount acc = new SysPropertyAccount();
        acc.setUsername(user.getUsername());
        acc.setPassword(user.getPassword());
        acc.setStaffId(staff.getStaffId());
        acc.setPermissionCode(user.getPermissionCode());
        acc.setStatus(StringUtils.hasText(user.getStatus()) ? user.getStatus() : "0");
        acc.setDelFlag("0");
        propertyAccountMapper.insert(acc);
        return acc.getAccountId();
    }

    private void updateOwnerAccount(SysUser user, SysUser db) {
        if (StringUtils.hasText(user.getPhone()) && !isSamePhone(user.getPhone(), db.getPhone())) {
            assertPhoneAvailable(user.getPhone().trim(), user.getUserId(), "0");
        }
        SysOwnerAccount accUpd = new SysOwnerAccount();
        accUpd.setAccountId(user.getUserId());
        if (user.getStatus() != null) {
            accUpd.setStatus(user.getStatus());
        }

        CmResident resident = resolveOwnerResident(user.getUserId(), db.getProfileRefId());
        if (resident != null) {
            CmResident upd = new CmResident();
            upd.setResidentId(resident.getResidentId());
            if (StringUtils.hasText(user.getNickName())) {
                upd.setName(user.getNickName());
            }
            if (StringUtils.hasText(user.getPhone())) {
                upd.setPhone(user.getPhone());
            }
            if (user.getGender() != null) {
                upd.setGender(user.getGender());
            }
            if (user.getAge() != null) {
                upd.setAge(user.getAge());
            }
            residentMapper.updateById(upd);
            linkOwnerAccountResident(user.getUserId(), resident.getResidentId());
            ownerAccountMapper.updateById(accUpd);
        } else {
            if (StringUtils.hasText(user.getNickName())) {
                accUpd.setBindName(user.getNickName().trim());
            }
            if (StringUtils.hasText(user.getPhone())) {
                accUpd.setBindPhone(user.getPhone().trim());
            }
            if (user.getGender() != null) {
                accUpd.setBindGender(user.getGender());
            }
            if (user.getAge() != null) {
                accUpd.setBindAge(user.getAge());
            }
            ownerAccountMapper.updateById(accUpd);
        }
    }

    private CmResident resolveOwnerResident(Long userId, Long profileRefId) {
        if (profileRefId != null) {
            CmResident resident = residentMapper.selectById(profileRefId);
            if (resident != null && "0".equals(resident.getDelFlag())) {
                return resident;
            }
        }
        return residentMapper.selectOne(new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getUserId, userId)
            .eq(CmResident::getDelFlag, "0")
            .last("LIMIT 1"));
    }

    private void linkOwnerAccountResident(Long userId, Long residentId) {
        SysOwnerAccount acc = ownerAccountMapper.selectById(userId);
        if (acc != null && acc.getResidentId() == null && residentId != null) {
            SysOwnerAccount link = new SysOwnerAccount();
            link.setAccountId(userId);
            link.setResidentId(residentId);
            ownerAccountMapper.updateById(link);
        }
    }

    private void updateWorkerAccount(SysUser user, SysUser db) {
        if (StringUtils.hasText(user.getPhone()) && !isSamePhone(user.getPhone(), db.getPhone())) {
            assertPhoneAvailable(user.getPhone().trim(), user.getUserId(), "1");
        }
        if (user.getStatus() != null) {
            SysWorkerAccount acc = new SysWorkerAccount();
            acc.setAccountId(user.getUserId());
            acc.setStatus(user.getStatus());
            workerAccountMapper.updateById(acc);
        }
        RpWorkerProfile upd = new RpWorkerProfile();
        upd.setWorkerId(user.getUserId());
        if (StringUtils.hasText(user.getNickName())) upd.setRealName(user.getNickName());
        if (StringUtils.hasText(user.getPhone())) upd.setPhone(user.getPhone());
        if (user.getGender() != null) upd.setGender(user.getGender());
        if (user.getAge() != null) upd.setAge(user.getAge());
        if (user.getAvatar() != null) upd.setAvatar(user.getAvatar());
        workerProfileMapper.updateById(upd);
    }

    private void updatePropertyAccount(SysUser user, SysUser db) {
        if (StringUtils.hasText(user.getPhone()) && !isSamePhone(user.getPhone(), db.getPhone())) {
            assertPhoneAvailable(user.getPhone().trim(), user.getUserId(), "2");
        }
        SysPropertyAccount accUpd = new SysPropertyAccount();
        accUpd.setAccountId(user.getUserId());
        if (user.getStatus() != null) accUpd.setStatus(user.getStatus());
        if (user.getPermissionCode() != null) accUpd.setPermissionCode(user.getPermissionCode());
        propertyAccountMapper.updateById(accUpd);

        if (db.getProfileRefId() != null) {
            PmStaff staff = new PmStaff();
            staff.setStaffId(db.getProfileRefId());
            if (StringUtils.hasText(user.getNickName())) staff.setName(user.getNickName());
            if (StringUtils.hasText(user.getPhone())) staff.setPhone(user.getPhone());
            if (user.getGender() != null) staff.setGender(user.getGender());
            if (user.getAge() != null) staff.setAge(user.getAge());
            if (user.getAvatar() != null) staff.setAvatar(user.getAvatar());
            staffMapper.updateById(staff);
        }
    }

    private boolean matchesUserQuery(SysUser user, String username, String nickName) {
        if (StringUtils.hasText(username)) {
            String kw = username.trim();
            if (user.getUsername() == null || !user.getUsername().contains(kw)) {
                return false;
            }
        }
        if (StringUtils.hasText(nickName)) {
            String kw = nickName.trim();
            if (user.getNickName() == null || !user.getNickName().contains(kw)) {
                return false;
            }
        }
        return true;
    }

    private List<SysUser> listOwners(String username) {
        LambdaQueryWrapper<SysOwnerAccount> qw = new LambdaQueryWrapper<SysOwnerAccount>()
            .eq(SysOwnerAccount::getDelFlag, "0")
            .like(StringUtils.hasText(username), SysOwnerAccount::getUsername, username);
        List<SysUser> list = new ArrayList<>();
        for (SysOwnerAccount acc : ownerAccountMapper.selectList(qw)) {
            SysUser u = loadOwnerById(acc.getAccountId());
            if (u != null) list.add(u);
        }
        return list;
    }

    private List<SysUser> listWorkers(String username) {
        LambdaQueryWrapper<SysWorkerAccount> qw = new LambdaQueryWrapper<SysWorkerAccount>()
            .eq(SysWorkerAccount::getDelFlag, "0")
            .like(StringUtils.hasText(username), SysWorkerAccount::getUsername, username);
        List<SysUser> list = new ArrayList<>();
        for (SysWorkerAccount acc : workerAccountMapper.selectList(qw)) {
            SysUser u = loadWorkerById(acc.getAccountId());
            if (u != null) list.add(u);
        }
        return list;
    }

    private List<SysUser> listPropertyUsers(String username) {
        LambdaQueryWrapper<SysPropertyAccount> qw = new LambdaQueryWrapper<SysPropertyAccount>()
            .eq(SysPropertyAccount::getDelFlag, "0")
            .like(StringUtils.hasText(username), SysPropertyAccount::getUsername, username);
        List<SysUser> list = new ArrayList<>();
        for (SysPropertyAccount acc : propertyAccountMapper.selectList(qw)) {
            SysUser u = loadPropertyById(acc.getAccountId());
            if (u != null) list.add(u);
        }
        return list;
    }

    private SysUser loadOwnerByUsername(String username) {
        SysOwnerAccount acc = ownerAccountMapper.selectOne(new LambdaQueryWrapper<SysOwnerAccount>()
            .eq(SysOwnerAccount::getUsername, username)
            .eq(SysOwnerAccount::getDelFlag, "0"));
        return acc == null ? null : loadOwnerById(acc.getAccountId());
    }

    private SysUser loadWorkerByUsername(String username) {
        SysWorkerAccount acc = workerAccountMapper.selectOne(new LambdaQueryWrapper<SysWorkerAccount>()
            .eq(SysWorkerAccount::getUsername, username)
            .eq(SysWorkerAccount::getDelFlag, "0"));
        return acc == null ? null : loadWorkerById(acc.getAccountId());
    }

    private SysUser loadPropertyByUsername(String username) {
        SysPropertyAccount acc = propertyAccountMapper.selectOne(new LambdaQueryWrapper<SysPropertyAccount>()
            .eq(SysPropertyAccount::getUsername, username)
            .eq(SysPropertyAccount::getDelFlag, "0"));
        return acc == null ? null : loadPropertyById(acc.getAccountId());
    }

    private SysUser loadOwnerById(Long accountId) {
        SysOwnerAccount acc = ownerAccountMapper.selectById(accountId);
        if (acc == null || "2".equals(acc.getDelFlag())) return null;
        CmResident resident = acc.getResidentId() != null
            ? residentMapper.selectById(acc.getResidentId()) : null;
        if (resident == null) {
            resident = residentMapper.selectOne(new LambdaQueryWrapper<CmResident>()
                .eq(CmResident::getUserId, accountId)
                .eq(CmResident::getDelFlag, "0")
                .last("LIMIT 1"));
        }
        SysUser u = buildUser(acc.getAccountId(), acc.getUsername(), acc.getPassword(), "0",
            acc.getStatus(), acc.getDelFlag(), acc.getCreateTime(), acc.getUpdateTime(),
            resident != null ? resident.getName() : StringUtils.hasText(acc.getBindName()) ? acc.getBindName() : acc.getUsername(),
            resident != null ? resident.getGender() : (StringUtils.hasText(acc.getBindGender()) ? acc.getBindGender() : ""),
            resident != null ? resident.getAge() : acc.getBindAge(),
            resident != null ? resident.getPhone() : StringUtils.hasText(acc.getBindPhone()) ? acc.getBindPhone() : "",
            resident != null ? resident.getIdCard() : "",
            "",
            resident != null ? resident.getHouseId() : null,
            null,
            resident != null ? resident.getResidentId() : null);
        u.setHouseAddress(resident != null ? formatHouseAddress(resident.getHouseId()) : "");
        u.setResidentBound(resident != null);
        return u;
    }

    private String formatHouseAddress(Long houseId) {
        if (houseId == null) {
            return "";
        }
        CmHouse house = houseMapper.selectById(houseId);
        if (house == null) {
            return "";
        }
        CmBuilding b = buildingMapper.selectById(house.getBuildingId());
        String buildingNo = b != null ? b.getBuildingNo() : "";
        return buildingNo + (StringUtils.hasText(house.getHouseNo()) ? "-" + house.getHouseNo() : "");
    }

    private SysUser loadWorkerById(Long accountId) {
        SysWorkerAccount acc = workerAccountMapper.selectById(accountId);
        if (acc == null || "2".equals(acc.getDelFlag())) return null;
        RpWorkerProfile profile = workerProfileMapper.selectById(accountId);
        String name = profile != null && StringUtils.hasText(profile.getRealName())
            ? profile.getRealName() : acc.getUsername();
        return buildUser(acc.getAccountId(), acc.getUsername(), acc.getPassword(), "1",
            acc.getStatus(), acc.getDelFlag(), acc.getCreateTime(), acc.getUpdateTime(),
            name,
            profile != null ? profile.getGender() : "",
            profile != null ? profile.getAge() : null,
            profile != null ? profile.getPhone() : "",
            "",
            profile != null ? profile.getAvatar() : "",
            null, null, accountId);
    }

    private SysUser loadPropertyById(Long accountId) {
        SysPropertyAccount acc = propertyAccountMapper.selectById(accountId);
        if (acc == null || "2".equals(acc.getDelFlag())) return null;
        PmStaff staff = acc.getStaffId() != null ? staffMapper.selectById(acc.getStaffId()) : null;
        String name = staff != null ? staff.getName() : acc.getUsername();
        return buildUser(acc.getAccountId(), acc.getUsername(), acc.getPassword(), "2",
            acc.getStatus(), acc.getDelFlag(), acc.getCreateTime(), acc.getUpdateTime(),
            name,
            staff != null ? staff.getGender() : "",
            staff != null ? staff.getAge() : null,
            staff != null ? staff.getPhone() : "",
            "",
            staff != null ? staff.getAvatar() : "",
            null,
            acc.getPermissionCode(),
            staff != null ? staff.getStaffId() : null);
    }

    private SysUser buildUser(Long userId, String username, String password, String userType,
                              String status, String delFlag,
                              java.time.LocalDateTime createTime, java.time.LocalDateTime updateTime,
                              String nickName, String gender, Integer age, String phone, String idCard,
                              String avatar, Long houseId, String permissionCode, Long profileRefId) {
        SysUser u = new SysUser();
        u.setUserId(userId);
        u.setUsername(username);
        u.setPassword(password);
        u.setUserType(userType);
        u.setStatus(status);
        u.setDelFlag(delFlag);
        u.setCreateTime(createTime);
        u.setUpdateTime(updateTime);
        u.setNickName(nickName);
        u.setGender(gender);
        u.setAge(age);
        u.setPhone(phone);
        u.setIdCard(idCard);
        u.setAvatar(avatar);
        u.setHouseId(houseId);
        u.setPermissionCode(permissionCode);
        u.setProfileRefId(profileRefId);
        return u;
    }

    private void assertUsernameAvailable(String username) {
        if (findByUsername(username) != null) {
            throw new ServiceException("账号已存在");
        }
    }

    private void assertPhoneAvailable(String phone, Long excludeUserId, String userType) {
        if (!assertPhoneAvailableQuiet(phone, excludeUserId, userType)) {
            throw new ServiceException("手机号已被使用");
        }
    }

    private boolean assertPhoneAvailableQuiet(String phone, Long excludeUserId, String userType) {
        if (!StringUtils.hasText(phone)) return true;
        if (!StringUtils.hasText(userType) || "0".equals(userType)) {
            long cnt = residentMapper.selectCount(new LambdaQueryWrapper<CmResident>()
                .eq(CmResident::getPhone, phone)
                .eq(CmResident::getDelFlag, "0")
                .ne(excludeUserId != null, CmResident::getUserId, excludeUserId));
            if (cnt > 0) return false;
        }
        if (!StringUtils.hasText(userType) || "1".equals(userType)) {
            long cnt = workerProfileMapper.selectCount(new LambdaQueryWrapper<RpWorkerProfile>()
                .eq(RpWorkerProfile::getPhone, phone)
                .ne(excludeUserId != null, RpWorkerProfile::getWorkerId, excludeUserId));
            if (cnt > 0) return false;
        }
        if (!StringUtils.hasText(userType) || "2".equals(userType)) {
            LambdaQueryWrapper<PmStaff> staffQw = new LambdaQueryWrapper<PmStaff>()
                .eq(PmStaff::getPhone, phone)
                .eq(PmStaff::getDelFlag, "0");
            if (excludeUserId != null) {
                SysPropertyAccount acc = propertyAccountMapper.selectById(excludeUserId);
                if (acc != null && acc.getStaffId() != null) {
                    staffQw.ne(PmStaff::getStaffId, acc.getStaffId());
                }
            }
            if (staffMapper.selectCount(staffQw) > 0) return false;
        }
        return true;
    }

    private static boolean isSamePhone(String left, String right) {
        if (!StringUtils.hasText(left) && !StringUtils.hasText(right)) {
            return true;
        }
        if (!StringUtils.hasText(left) || !StringUtils.hasText(right)) {
            return false;
        }
        return left.trim().equals(right.trim());
    }

    public Map<Long, String> findDisplayNames(java.util.Collection<Long> userIds) {
        Map<Long, String> map = new HashMap<>();
        if (userIds == null) {
            return map;
        }
        for (Long id : userIds) {
            SysUser u = findById(id);
            if (u != null && StringUtils.hasText(u.getNickName())) {
                map.put(id, u.getNickName());
            }
        }
        return map;
    }

    public List<SysUser> listByUserType(String userType) {
        return pageList(1, 500, null, null, userType).getRecords();
    }

    /** 可绑定住户档案的业主（未绑定档案，或排除当前编辑档案已绑定的账号） */
    public List<Map<String, Object>> listOwnerBindOptions(Long excludeResidentId) {
        Long excludeUserId = null;
        if (excludeResidentId != null) {
            CmResident cur = residentMapper.selectById(excludeResidentId);
            if (cur != null) {
                excludeUserId = cur.getUserId();
            }
        }
        List<Map<String, Object>> options = new ArrayList<>();
        for (SysOwnerAccount acc : ownerAccountMapper.selectList(
            new LambdaQueryWrapper<SysOwnerAccount>().eq(SysOwnerAccount::getDelFlag, "0"))) {
            boolean bound = acc.getResidentId() != null;
            if (!bound) {
                long cnt = residentMapper.selectCount(new LambdaQueryWrapper<CmResident>()
                    .eq(CmResident::getUserId, acc.getAccountId())
                    .eq(CmResident::getDelFlag, "0")
                    .ne(excludeResidentId != null, CmResident::getResidentId, excludeResidentId));
                bound = cnt > 0;
            }
            if (bound && !Objects.equals(acc.getAccountId(), excludeUserId)) {
                continue;
            }
            SysUser u = loadOwnerById(acc.getAccountId());
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("userId", acc.getAccountId());
            m.put("username", acc.getUsername());
            m.put("nickName", u != null ? u.getNickName() : acc.getUsername());
            m.put("phone", u != null ? u.getPhone() : "");
            m.put("gender", u != null ? u.getGender() : "");
            m.put("age", u != null ? u.getAge() : null);
            options.add(m);
        }
        return options;
    }

    /** 绑定业主账号与住户档案，姓名以住户档案为准 */
    public void bindOwnerResident(Long userId, Long residentId, String name, String phone) {
        if (userId == null || residentId == null) {
            throw new ServiceException("业主账号与住户档案不能为空");
        }
        SysOwnerAccount acc = ownerAccountMapper.selectById(userId);
        if (acc == null || "2".equals(acc.getDelFlag())) {
            throw new ServiceException("业主账号不存在");
        }
        CmResident other = residentMapper.selectOne(new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getUserId, userId)
            .eq(CmResident::getDelFlag, "0")
            .ne(CmResident::getResidentId, residentId)
            .last("LIMIT 1"));
        if (other != null) {
            throw new ServiceException("该业主账号已绑定其他住户档案");
        }
        ownerAccountMapper.update(null, new LambdaUpdateWrapper<SysOwnerAccount>()
            .eq(SysOwnerAccount::getAccountId, userId)
            .set(SysOwnerAccount::getResidentId, residentId)
            .set(SysOwnerAccount::getBindName, null)
            .set(SysOwnerAccount::getBindPhone, null));
    }

    /** 根据手机号自动匹配未绑定的业主账号（与业主管理中预填信息一致） */
    public Long resolveOwnerAccountId(String phone, String name, Long residentId) {
        if (residentId != null) {
            CmResident db = residentMapper.selectById(residentId);
            if (db != null && db.getUserId() != null) {
                return db.getUserId();
            }
            SysOwnerAccount byRes = ownerAccountMapper.selectOne(new LambdaQueryWrapper<SysOwnerAccount>()
                .eq(SysOwnerAccount::getResidentId, residentId)
                .eq(SysOwnerAccount::getDelFlag, "0")
                .last("LIMIT 1"));
            if (byRes != null) {
                return byRes.getAccountId();
            }
        }
        if (!StringUtils.hasText(phone)) {
            throw new ServiceException("请填写联系电话，并与业主管理中的手机号保持一致");
        }
        String p = phone.trim();
        for (SysOwnerAccount acc : ownerAccountMapper.selectList(
            new LambdaQueryWrapper<SysOwnerAccount>().eq(SysOwnerAccount::getDelFlag, "0"))) {
            if (isOwnerBoundToOther(acc, residentId)) {
                continue;
            }
            if (p.equals(acc.getBindPhone())) {
                return acc.getAccountId();
            }
            CmResident linked = findLinkedResident(acc);
            if (linked != null && p.equals(linked.getPhone())) {
                return acc.getAccountId();
            }
        }
        if (StringUtils.hasText(name)) {
            String n = name.trim();
            for (SysOwnerAccount acc : ownerAccountMapper.selectList(
                new LambdaQueryWrapper<SysOwnerAccount>().eq(SysOwnerAccount::getDelFlag, "0"))) {
                if (isOwnerBoundToOther(acc, residentId)) {
                    continue;
                }
                if (n.equals(acc.getBindName())) {
                    return acc.getAccountId();
                }
            }
        }
        throw new ServiceException("未找到匹配的业主账号，请先在业主管理中创建账号（手机号与姓名一致）");
    }

    private boolean isOwnerBoundToOther(SysOwnerAccount acc, Long excludeResidentId) {
        if (acc.getResidentId() != null && !Objects.equals(acc.getResidentId(), excludeResidentId)) {
            return true;
        }
        CmResident linked = residentMapper.selectOne(new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getUserId, acc.getAccountId())
            .eq(CmResident::getDelFlag, "0")
            .ne(excludeResidentId != null, CmResident::getResidentId, excludeResidentId)
            .last("LIMIT 1"));
        return linked != null;
    }

    private CmResident findLinkedResident(SysOwnerAccount acc) {
        if (acc.getResidentId() != null) {
            return residentMapper.selectById(acc.getResidentId());
        }
        return residentMapper.selectOne(new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getUserId, acc.getAccountId())
            .eq(CmResident::getDelFlag, "0")
            .last("LIMIT 1"));
    }

    public List<SysUser> findByIds(List<Long> userIds) {
        if (userIds == null || userIds.isEmpty()) {
            return List.of();
        }
        List<SysUser> list = new ArrayList<>();
        for (Long id : userIds) {
            SysUser u = findById(id);
            if (u != null) {
                list.add(u);
            }
        }
        return list;
    }

    private String normalizeType(String userType) {
        if ("3".equals(userType)) return "2";
        return userType != null ? userType : "0";
    }
}
