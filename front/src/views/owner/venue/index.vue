<template>
  <div>
    <el-tabs v-model="tab">
      <el-tab-pane label="预约场地" name="book">
        <el-form inline>
          <el-form-item label="场地">
            <el-select v-model="bookForm.venueId" @change="loadSlots">
              <el-option v-for="v in venues" :key="v.venueId" :label="v.venueName" :value="v.venueId" />
            </el-select>
          </el-form-item>
          <el-form-item label="日期">
            <el-date-picker v-model="bookForm.bookDate" type="date" value-format="YYYY-MM-DD" @change="loadSlots" />
          </el-form-item>
        </el-form>
        <el-table :data="slots">
          <el-table-column prop="timeSlot" label="时段" />
          <el-table-column prop="feeStandard" label="费用(元)" />
          <el-table-column label="状态">
            <template #default="{ row }">{{ row.available ? '可预约' : '已占用' }}</template>
          </el-table-column>
          <el-table-column label="操作" width="100">
            <template #default="{ row }">
              <el-button v-if="row.available" link type="primary" @click="doBook(row)">预约</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
      <el-tab-pane label="我的预约" name="mine">
        <el-table :data="bookings">
          <el-table-column prop="venueId" label="场地ID" width="80" />
          <el-table-column prop="bookDate" label="日期" width="120" />
          <el-table-column prop="timeSlot" label="时段" />
          <el-table-column prop="status" label="状态" width="90">
            <template #default="{ row }">{{ { '0':'待审','1':'通过','2':'取消' }[row.status] }}</template>
          </el-table-column>
          <el-table-column label="操作" width="160">
            <template #default="{ row }">
              <el-button v-if="row.status === '1'" link @click="openEdit(row)">改期</el-button>
              <el-button v-if="row.status === '1'" link type="danger" @click="cancel(row)">取消</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>
    <el-dialog v-model="editVisible" title="修改预约" width="400px">
      <el-date-picker v-model="editForm.bookDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
      <el-select v-model="editForm.timeSlot" class="mt-8" style="width:100%">
        <el-option label="09:00-12:00" value="09:00-12:00" />
        <el-option label="14:00-17:00" value="14:00-17:00" />
        <el-option label="18:00-21:00" value="18:00-21:00" />
      </el-select>
      <template #footer><el-button type="primary" @click="saveEdit">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listVenue, getVenueSlots, bookVenue, listMyVenueBooking, cancelVenueBooking, updateVenueBooking } from '@/api/owner'

const tab = ref('book')
const venues = ref([])
const slots = ref([])
const bookings = ref([])
const bookForm = reactive({ venueId: null, bookDate: '' })
const editVisible = ref(false)
const editForm = reactive({ bookingId: null, venueId: null, bookDate: '', timeSlot: '' })

async function loadVenues() {
  venues.value = (await listVenue()).data
  if (venues.value.length) {
    bookForm.venueId = venues.value[0].venueId
    bookForm.bookDate = new Date().toISOString().slice(0, 10)
    loadSlots()
  }
  bookings.value = (await listMyVenueBooking()).data
}

async function loadSlots() {
  if (!bookForm.venueId || !bookForm.bookDate) return
  slots.value = (await getVenueSlots({ venueId: bookForm.venueId, bookDate: bookForm.bookDate })).data
}

async function doBook(row) {
  await bookVenue({ venueId: bookForm.venueId, bookDate: bookForm.bookDate, timeSlot: row.timeSlot })
  ElMessage.success('预约成功')
  loadVenues()
}

function openEdit(row) {
  Object.assign(editForm, row)
  editVisible.value = true
}

async function saveEdit() {
  await updateVenueBooking(editForm)
  ElMessage.success('已修改')
  editVisible.value = false
  loadVenues()
}

async function cancel(row) {
  await ElMessageBox.confirm('需提前24小时取消，确定？', '提示')
  await cancelVenueBooking(row.bookingId)
  ElMessage.success('已取消')
  loadVenues()
}

onMounted(loadVenues)
</script>

<style scoped>.mt-8{margin-top:8px}</style>
