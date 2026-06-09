<template>
  <div>
    <el-tabs v-model="tab" @tab-change="onTabChange">
      <!-- 楼栋房屋 -->
      <el-tab-pane label="楼栋房屋" name="building">
        <el-row :gutter="16">
          <el-col :span="8">
            <el-card>
              <template #header>
                <span>楼栋</span>
                <el-button type="primary" link class="fr" @click="openBuilding()">新增</el-button>
              </template>
              <el-table :data="buildings" highlight-current-row @row-click="selectBuilding">
                <el-table-column prop="buildingNo" label="楼栋号" />
                <el-table-column prop="totalFloors" label="层数" width="60" />
                <el-table-column prop="unitsPerFloor" label="每层户" width="70" />
              </el-table>
            </el-card>
          </el-col>
          <el-col :span="16">
            <el-card>
              <template #header>
                <span>房屋{{ curBuilding ? ` - ${curBuilding.buildingNo}` : '' }}</span>
                <el-button type="primary" link class="fr" :disabled="!curBuilding" @click="openHouse()">录入房屋</el-button>
              </template>
              <el-table :data="houses">
                <el-table-column prop="houseNo" label="房号" width="80" />
                <el-table-column prop="area" label="面积" width="70" />
                <el-table-column prop="layout" label="户型" />
                <el-table-column prop="ownerName" label="业主" />
                <el-table-column label="租赁" width="80">
                  <template #default="{ row }">{{ rentMap[row.rentStatus] }}</template>
                </el-table-column>
              </el-table>
            </el-card>
          </el-col>
        </el-row>
      </el-tab-pane>

      <!-- 设备 -->
      <el-tab-pane label="公共设备" name="equipment">
        <el-button type="primary" class="mb-16" @click="openEquip()">录入设备</el-button>
        <el-table :data="equipments">
          <el-table-column prop="equipType" label="类型" width="90">
            <template #default="{ row }">{{ equipMap[row.equipType] }}</template>
          </el-table-column>
          <el-table-column prop="equipNo" label="编号" />
          <el-table-column prop="location" label="位置" />
          <el-table-column prop="iotStatus" label="状态" width="90" />
          <el-table-column label="操作" width="80">
            <template #default="{ row }">
              <el-button link type="danger" @click="delEquip(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <!-- 住户 -->
      <el-tab-pane label="住户档案" name="resident">
        <el-form inline class="mb-16">
          <el-form-item label="楼栋">
            <el-select v-model="q.buildingId" clearable style="width:120px" @change="loadResidents">
              <el-option v-for="b in buildings" :key="b.buildingId" :label="b.buildingNo" :value="b.buildingId" />
            </el-select>
          </el-form-item>
          <el-form-item label="标签">
            <el-select v-model="q.tagId" clearable style="width:120px" @change="loadResidents">
              <el-option v-for="t in tags" :key="t.tagId" :label="t.tagName" :value="t.tagId" />
            </el-select>
          </el-form-item>
          <el-form-item label="姓名">
            <el-input v-model="q.name" clearable style="width:120px" @keyup.enter="loadResidents" />
          </el-form-item>
          <el-button type="primary" @click="loadResidents">搜索</el-button>
          <el-button type="success" @click="openResident()">创建档案</el-button>
          <el-button @click="openTag()">自定义标签</el-button>
        </el-form>
        <el-table :data="residents" v-loading="resLoading">
          <el-table-column prop="buildingNo" label="楼栋" width="70" />
          <el-table-column prop="houseNo" label="房号" width="70" />
          <el-table-column prop="name" label="姓名" width="90" />
          <el-table-column prop="phone" label="电话" width="120" />
          <el-table-column prop="residentType" label="类型" width="70">
            <template #default="{ row }">{{ row.residentType === '0' ? '业主' : '租客' }}</template>
          </el-table-column>
          <el-table-column label="标签" show-overflow-tooltip>
            <template #default="{ row }">{{ tagNames(row.tagIds) }}</template>
          </el-table-column>
          <el-table-column label="操作" width="140">
            <template #default="{ row }">
              <el-button link @click="openResident(row)">编辑</el-button>
              <el-button link type="danger" @click="delResident(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <!-- 租赁 -->
      <el-tab-pane label="房屋租赁" name="rent">
        <el-radio-group v-model="rentFilter" class="mb-16" @change="loadRent">
          <el-radio-button label="">全部</el-radio-button>
          <el-radio-button label="0">空置</el-radio-button>
          <el-radio-button label="1">已租</el-radio-button>
          <el-radio-button label="2">待退租</el-radio-button>
        </el-radio-group>
        <el-table :data="rentList">
          <el-table-column prop="buildingNo" label="楼栋" width="70" />
          <el-table-column prop="houseNo" label="房号" width="70" />
          <el-table-column prop="ownerName" label="业主" />
          <el-table-column prop="tenantName" label="租客" />
          <el-table-column prop="tenantPhone" label="租客电话" width="120" />
          <el-table-column prop="leaseStart" label="租期起" width="110" />
          <el-table-column prop="leaseEnd" label="租期止" width="110" />
          <el-table-column prop="rentAmount" label="租金" width="80" />
          <el-table-column label="操作" width="80">
            <template #default="{ row }">
              <el-button link @click="editRent(row)">修改</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <!-- 车位 -->
      <el-tab-pane label="车位管理" name="parking">
        <el-button type="primary" class="mb-16" @click="openParking()">新增车位</el-button>
        <el-button class="mb-16" @click="payDlg = true">登记缴费</el-button>
        <el-table :data="parkings">
          <el-table-column prop="parkingNo" label="编号" />
          <el-table-column prop="monthlyFee" label="月租" width="80" />
          <el-table-column prop="yearlyFee" label="年租" width="80" />
          <el-table-column prop="status" label="状态" width="80">
            <template #default="{ row }">{{ row.status === '1' ? '已绑定' : '空闲' }}</template>
          </el-table-column>
          <el-table-column prop="residentName" label="绑定住户" />
          <el-table-column label="操作" width="180">
            <template #default="{ row }">
              <el-button v-if="row.status !== '1'" link @click="bindPark(row)">绑定</el-button>
              <el-button v-else link type="warning" @click="unbindPark(row)">解绑</el-button>
              <el-button link @click="editParkFee(row)">改费用</el-button>
            </template>
          </el-table-column>
        </el-table>
        <h4 class="mt-16">缴费记录</h4>
        <el-form inline class="mb-8">
          <el-form-item label="车位号"><el-input v-model="payQ.parkingNo" style="width:100px" /></el-form-item>
          <el-button @click="loadPayments">查询</el-button>
        </el-form>
        <el-table :data="payments" size="small">
          <el-table-column prop="parkingId" label="车位ID" width="80" />
          <el-table-column prop="amount" label="金额" width="80" />
          <el-table-column prop="payType" label="类型" width="80" />
          <el-table-column prop="periodStart" label="起始" width="110" />
          <el-table-column prop="periodEnd" label="截止" width="110" />
          <el-table-column prop="payTime" label="缴费时间" />
        </el-table>
      </el-tab-pane>

      <!-- 入住迁出 -->
      <el-tab-pane label="入住迁出" name="move">
        <el-button type="primary" class="mb-16" @click="openMove()">登记申请</el-button>
        <el-radio-group v-model="moveFilter" class="mb-16" @change="loadMoves">
          <el-radio-button label="0">待审批</el-radio-button>
          <el-radio-button label="">全部</el-radio-button>
        </el-radio-group>
        <el-table :data="moves">
          <el-table-column prop="applicantName" label="申请人" width="90" />
          <el-table-column prop="buildingNo" label="楼栋" width="70" />
          <el-table-column prop="houseNo" label="房号" width="70" />
          <el-table-column prop="applyType" label="类型" width="80">
            <template #default="{ row }">{{ row.applyType === '0' ? '入住' : '迁出' }}</template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="80">
            <template #default="{ row }">{{ moveStatus[row.status] }}</template>
          </el-table-column>
          <el-table-column prop="createTime" label="申请时间" width="170" />
          <el-table-column label="操作" width="160">
            <template #default="{ row }">
              <template v-if="row.status === '0'">
                <el-button link type="success" @click="doAuditPass(row)">通过</el-button>
                <el-button link type="danger" @click="rejectMove(row)">驳回</el-button>
              </template>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <!-- 违规 -->
      <el-tab-pane label="违规住户" name="violation">
        <el-button type="primary" class="mb-16" @click="openViolation()">标记违规</el-button>
        <el-table :data="violations">
          <el-table-column prop="residentName" label="住户" />
          <el-table-column prop="violationType" label="类型" />
          <el-table-column prop="measure" label="措施" show-overflow-tooltip />
          <el-table-column prop="unlockDate" label="解封日" width="110" />
          <el-table-column prop="status" label="状态" width="80">
            <template #default="{ row }">{{ row.status === '1' ? '黑名单' : '已解除' }}</template>
          </el-table-column>
          <el-table-column label="操作" width="140">
            <template #default="{ row }">
              <el-button link @click="editViolation(row)">修改</el-button>
              <el-button v-if="row.status === '1'" link @click="liftViolation(row)">移出黑名单</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <!-- 楼栋 -->
    <el-dialog v-model="buildingDlg" title="楼栋" width="400px">
      <el-form :model="buildingForm" label-width="90px">
        <el-form-item label="楼栋号"><el-input v-model="buildingForm.buildingNo" /></el-form-item>
        <el-form-item label="总层数"><el-input-number v-model="buildingForm.totalFloors" :min="1" /></el-form-item>
        <el-form-item label="每层户数"><el-input-number v-model="buildingForm.unitsPerFloor" :min="1" /></el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveBuilding">保存</el-button></template>
    </el-dialog>

    <!-- 房屋 -->
    <el-dialog v-model="houseDlg" title="房屋" width="440px">
      <el-form :model="houseForm" label-width="90px">
        <el-form-item label="房号"><el-input v-model="houseForm.houseNo" /></el-form-item>
        <el-form-item label="面积"><el-input v-model="houseForm.area" /></el-form-item>
        <el-form-item label="户型"><el-input v-model="houseForm.layout" /></el-form-item>
        <el-form-item label="业主"><el-input v-model="houseForm.ownerName" /></el-form-item>
        <el-form-item label="租赁状态">
          <el-select v-model="houseForm.rentStatus">
            <el-option label="空置" value="0" /><el-option label="已租" value="1" /><el-option label="待退租" value="2" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveHouse">保存</el-button></template>
    </el-dialog>

    <!-- 设备 -->
    <el-dialog v-model="equipDlg" title="设备" width="420px">
      <el-form :model="equipForm" label-width="90px">
        <el-form-item label="类型">
          <el-select v-model="equipForm.equipType">
            <el-option label="电梯" value="elevator" /><el-option label="门禁" value="door" /><el-option label="路灯" value="light" />
          </el-select>
        </el-form-item>
        <el-form-item label="编号"><el-input v-model="equipForm.equipNo" /></el-form-item>
        <el-form-item label="位置"><el-input v-model="equipForm.location" /></el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveEquip">保存</el-button></template>
    </el-dialog>

    <!-- 住户 -->
    <el-dialog v-model="residentDlg" :title="residentForm.residentId ? '编辑住户' : '创建住户'" width="520px">
      <el-form :model="residentForm" label-width="100px">
        <el-form-item label="姓名"><el-input v-model="residentForm.name" /></el-form-item>
        <el-form-item label="身份证"><el-input v-model="residentForm.idCard" /></el-form-item>
        <el-form-item label="电话"><el-input v-model="residentForm.phone" /></el-form-item>
        <el-form-item label="房屋ID"><el-input v-model.number="residentForm.houseId" /></el-form-item>
        <el-form-item label="类型">
          <el-select v-model="residentForm.residentType"><el-option label="业主" value="0" /><el-option label="租客" value="1" /></el-select>
        </el-form-item>
        <el-form-item label="入住日期"><el-date-picker v-model="residentForm.moveInDate" type="date" value-format="YYYY-MM-DD" /></el-form-item>
        <el-form-item label="紧急联系人"><el-input v-model="residentForm.emergencyContact" /></el-form-item>
        <el-form-item label="家庭成员"><el-input v-model="residentForm.familyMembers" type="textarea" rows="2" /></el-form-item>
        <el-form-item label="标签">
          <el-select v-model="residentForm.tagIds" multiple style="width:100%">
            <el-option v-for="t in tags" :key="t.tagId" :label="t.tagName" :value="t.tagId" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveResident">保存</el-button></template>
    </el-dialog>

    <!-- 标签 -->
    <el-dialog v-model="tagDlg" title="新增标签" width="360px">
      <el-form :model="tagForm" label-width="80px">
        <el-form-item label="名称"><el-input v-model="tagForm.tagName" /></el-form-item>
        <el-form-item label="类型">
          <el-select v-model="tagForm.tagType">
            <el-option label="老人" value="elder" /><el-option label="残疾" value="disabled" /><el-option label="自定义" value="custom" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveTag">保存</el-button></template>
    </el-dialog>

    <!-- 租赁编辑 -->
    <el-dialog v-model="rentDlg" title="租赁信息" width="440px">
      <el-form :model="rentForm" label-width="90px">
        <el-form-item label="状态">
          <el-select v-model="rentForm.rentStatus">
            <el-option label="空置" value="0" /><el-option label="已租" value="1" /><el-option label="待退租" value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="租客"><el-input v-model="rentForm.tenantName" /></el-form-item>
        <el-form-item label="电话"><el-input v-model="rentForm.tenantPhone" /></el-form-item>
        <el-form-item label="租期起"><el-date-picker v-model="rentForm.leaseStart" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="租期止"><el-date-picker v-model="rentForm.leaseEnd" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="租金"><el-input v-model="rentForm.rentAmount" /></el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveRent">保存</el-button></template>
    </el-dialog>

    <!-- 车位 -->
    <el-dialog v-model="parkingDlg" title="车位" width="400px">
      <el-form :model="parkingForm" label-width="80px">
        <el-form-item label="编号"><el-input v-model="parkingForm.parkingNo" /></el-form-item>
        <el-form-item label="月租"><el-input v-model="parkingForm.monthlyFee" /></el-form-item>
        <el-form-item label="年租"><el-input v-model="parkingForm.yearlyFee" /></el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveParking">保存</el-button></template>
    </el-dialog>

    <el-dialog v-model="payDlg" title="车位缴费" width="440px">
      <el-form :model="payForm" label-width="90px">
        <el-form-item label="车位ID"><el-input v-model.number="payForm.parkingId" /></el-form-item>
        <el-form-item label="住户ID"><el-input v-model.number="payForm.residentId" /></el-form-item>
        <el-form-item label="金额"><el-input v-model="payForm.amount" /></el-form-item>
        <el-form-item label="类型"><el-select v-model="payForm.payType"><el-option label="月租" value="monthly" /><el-option label="年租" value="yearly" /></el-select></el-form-item>
        <el-form-item label="起始"><el-date-picker v-model="payForm.periodStart" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="截止"><el-date-picker v-model="payForm.periodEnd" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="savePayment">保存</el-button></template>
    </el-dialog>

    <!-- 入住迁出 -->
    <el-dialog v-model="moveDlg" title="入住/迁出申请" width="420px">
      <el-form :model="moveForm" label-width="90px">
        <el-form-item label="类型">
          <el-select v-model="moveForm.applyType"><el-option label="入住" value="0" /><el-option label="迁出" value="1" /></el-select>
        </el-form-item>
        <el-form-item label="申请人"><el-input v-model="moveForm.applicantName" /></el-form-item>
        <el-form-item label="电话"><el-input v-model="moveForm.applicantPhone" /></el-form-item>
        <el-form-item label="房屋ID"><el-input v-model.number="moveForm.houseId" /></el-form-item>
        <el-form-item v-if="moveForm.applyType === '1'" label="住户ID"><el-input v-model.number="moveForm.residentId" /></el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveMove">提交</el-button></template>
    </el-dialog>

    <!-- 违规 -->
    <el-dialog v-model="violationDlg" title="违规住户" width="440px">
      <el-form :model="violationForm" label-width="90px">
        <el-form-item label="住户ID"><el-input v-model.number="violationForm.residentId" /></el-form-item>
        <el-form-item label="类型"><el-input v-model="violationForm.violationType" /></el-form-item>
        <el-form-item label="措施"><el-input v-model="violationForm.measure" type="textarea" /></el-form-item>
        <el-form-item label="解封日"><el-date-picker v-model="violationForm.unlockDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveViolation">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  listBuilding, addBuilding, listHouse, addHouse, updateHouse,
  listEquipment, addEquipment, deleteEquipment,
  listTag, addTag, listResident, addResident, updateResident, deleteResident,
  listRentHouse, listParking, addParking, updateParking, bindParking, unbindParking,
  listParkingPayment, addParkingPayment, listViolation, addViolation, updateViolation, removeViolation,
  listMove, addMove, auditMove as auditMoveApi
} from '@/api/property'

const tab = ref('building')
const rentMap = { '0': '空置', '1': '已租', '2': '待退租' }
const equipMap = { elevator: '电梯', door: '门禁', light: '路灯' }
const moveStatus = { '0': '待审', '1': '通过', '2': '驳回' }

const buildings = ref([])
const curBuilding = ref(null)
const houses = ref([])
const equipments = ref([])
const tags = ref([])
const residents = ref([])
const resLoading = ref(false)
const q = reactive({ buildingId: null, tagId: null, name: '' })
const rentFilter = ref('')
const rentList = ref([])
const parkings = ref([])
const payments = ref([])
const payQ = reactive({ parkingNo: '' })
const moves = ref([])
const moveFilter = ref('0')
const violations = ref([])

const buildingDlg = ref(false)
const buildingForm = reactive({ buildingId: null, buildingNo: '', totalFloors: 18, unitsPerFloor: 4 })
const houseDlg = ref(false)
const houseForm = reactive({ houseId: null, buildingId: null, houseNo: '', area: 0, layout: '', ownerName: '', rentStatus: '0' })
const equipDlg = ref(false)
const equipForm = reactive({ equipType: 'elevator', equipNo: '', location: '' })
const residentDlg = ref(false)
const residentForm = reactive({ residentId: null, name: '', idCard: '', phone: '', houseId: 1, residentType: '0', moveInDate: '', emergencyContact: '', familyMembers: '', tagIds: [] })
const tagDlg = ref(false)
const tagForm = reactive({ tagName: '', tagType: 'custom' })
const rentDlg = ref(false)
const rentForm = reactive({ houseId: null, rentStatus: '1', tenantName: '', tenantPhone: '', leaseStart: '', leaseEnd: '', rentAmount: 0 })
const parkingDlg = ref(false)
const parkingForm = reactive({ parkingNo: '', monthlyFee: 300, yearlyFee: 3000 })
const payDlg = ref(false)
const payForm = reactive({ parkingId: null, residentId: null, amount: 0, payType: 'monthly', periodStart: '', periodEnd: '' })
const moveDlg = ref(false)
const moveForm = reactive({ applyType: '0', applicantName: '', applicantPhone: '', houseId: 1, residentId: null })
const violationDlg = ref(false)
const violationForm = reactive({ violationId: null, residentId: null, violationType: '', measure: '', unlockDate: '' })

function tagNames(ids) {
  if (!ids?.length) return ''
  return ids.map(id => tags.value.find(t => t.tagId === id)?.tagName).filter(Boolean).join('、')
}

async function loadBuildings() {
  buildings.value = (await listBuilding()).data
}
async function loadTags() {
  tags.value = (await listTag()).data
}
async function selectBuilding(row) {
  curBuilding.value = row
  houses.value = (await listHouse({ buildingId: row.buildingId })).data
}
function openBuilding() {
  Object.assign(buildingForm, { buildingId: null, buildingNo: '', totalFloors: 18, unitsPerFloor: 4 })
  buildingDlg.value = true
}
async function saveBuilding() {
  await addBuilding(buildingForm)
  ElMessage.success('已保存')
  buildingDlg.value = false
  loadBuildings()
}
function openHouse() {
  Object.assign(houseForm, { houseId: null, buildingId: curBuilding.value.buildingId, houseNo: '', area: 89, layout: '', ownerName: '', rentStatus: '0' })
  houseDlg.value = true
}
async function saveHouse() {
  await addHouse(houseForm)
  ElMessage.success('已录入')
  houseDlg.value = false
  selectBuilding(curBuilding.value)
}
function openEquip() {
  Object.assign(equipForm, { equipType: 'elevator', equipNo: '', location: '' })
  equipDlg.value = true
}
async function saveEquip() {
  await addEquipment(equipForm)
  equipDlg.value = false
  equipments.value = (await listEquipment()).data
}
async function delEquip(row) {
  await deleteEquipment(row.equipmentId)
  equipments.value = (await listEquipment()).data
}
async function loadResidents() {
  resLoading.value = true
  try {
    const res = await listResident({ pageNum: 1, pageSize: 50, ...q })
    residents.value = res.data.rows
  } finally { resLoading.value = false }
}
function openResident(row) {
  if (row) Object.assign(residentForm, { ...row, tagIds: row.tagIds || [] })
  else Object.assign(residentForm, { residentId: null, name: '', idCard: '', phone: '', houseId: 1, residentType: '0', tagIds: [] })
  residentDlg.value = true
}
async function saveResident() {
  if (residentForm.residentId) await updateResident(residentForm)
  else await addResident(residentForm)
  ElMessage.success('已保存')
  residentDlg.value = false
  loadResidents()
}
async function delResident(row) {
  await ElMessageBox.confirm('删除前请确保已解除车位绑定及未完结工单', '提示')
  await deleteResident(row.residentId)
  ElMessage.success('已删除')
  loadResidents()
}
function openTag() { tagForm.tagName = ''; tagDlg.value = true }
async function saveTag() {
  await addTag(tagForm)
  tagDlg.value = false
  loadTags()
}
async function loadRent() {
  rentList.value = (await listRentHouse({ rentStatus: rentFilter.value || undefined })).data
}
function editRent(row) {
  Object.assign(rentForm, row)
  rentDlg.value = true
}
async function saveRent() {
  await updateHouse(rentForm)
  rentDlg.value = false
  loadRent()
}
function openParking() { parkingDlg.value = true }
async function saveParking() {
  await addParking(parkingForm)
  parkingDlg.value = false
  parkings.value = (await listParking()).data
}
async function bindPark(row) {
  const { value } = await ElMessageBox.prompt('请输入住户ID', '绑定车位')
  await bindParking({ parkingId: row.parkingId, residentId: Number(value) })
  parkings.value = (await listParking()).data
}
async function unbindPark(row) {
  await unbindParking(row.parkingId)
  parkings.value = (await listParking()).data
}
async function editParkFee(row) {
  const { value } = await ElMessageBox.prompt('月租费用', '修改', { inputValue: row.monthlyFee })
  await updateParking({ parkingId: row.parkingId, parkingNo: row.parkingNo, monthlyFee: value, yearlyFee: row.yearlyFee, status: row.status })
  parkings.value = (await listParking()).data
}
async function loadPayments() {
  payments.value = (await listParkingPayment(payQ)).data
}
async function savePayment() {
  await addParkingPayment(payForm)
  payDlg.value = false
  loadPayments()
}
async function loadMoves() {
  moves.value = (await listMove({ status: moveFilter.value || undefined })).data
}
function openMove() { moveDlg.value = true }
async function saveMove() {
  await addMove(moveForm)
  moveDlg.value = false
  loadMoves()
}
async function doAuditPass(row) {
  await auditMoveApi({ applyId: row.applyId, pass: true })
  ElMessage.success('已通过')
  loadMoves()
}
async function rejectMove(row) {
  const { value } = await ElMessageBox.prompt('驳回理由', '驳回', { inputPattern: /.+/, inputErrorMessage: '必填' })
  await auditMoveApi({ applyId: row.applyId, pass: false, rejectReason: value })
  loadMoves()
}
function openViolation() {
  Object.assign(violationForm, { violationId: null, residentId: null, violationType: '', measure: '', unlockDate: '' })
  violationDlg.value = true
}
function editViolation(row) {
  Object.assign(violationForm, row)
  violationDlg.value = true
}
async function saveViolation() {
  if (violationForm.violationId) await updateViolation(violationForm)
  else await addViolation(violationForm)
  violationDlg.value = false
  violations.value = (await listViolation()).data
}
async function liftViolation(row) {
  await removeViolation(row.violationId)
  violations.value = (await listViolation({ status: '1' })).data
}

function onTabChange(name) {
  if (name === 'resident') loadResidents()
  if (name === 'rent') loadRent()
  if (name === 'parking') { listParking().then(r => { parkings.value = r.data }); loadPayments() }
  if (name === 'move') loadMoves()
  if (name === 'violation') listViolation({ status: '1' }).then(r => { violations.value = r.data })
  if (name === 'equipment') listEquipment().then(r => { equipments.value = r.data })
}

onMounted(async () => {
  await loadBuildings()
  await loadTags()
  if (buildings.value.length) selectBuilding(buildings.value[0])
})
</script>

<style scoped>
.mb-16 { margin-bottom: 16px; }
.mb-8 { margin-bottom: 8px; }
.mt-16 { margin-top: 16px; }
.fr { float: right; }
</style>
