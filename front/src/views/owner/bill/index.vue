<template>
  <div>
    <el-tabs v-model="tab">
      <el-tab-pane label="账单查询" name="bill">
        <el-form inline class="mb-16">
          <el-form-item label="账期">
            <el-input v-model="period" placeholder="如 2026-05" style="width:140px" clearable />
          </el-form-item>
          <el-form-item label="类型">
            <el-select v-model="feeType" clearable style="width:120px">
              <el-option label="物业费" value="property" />
              <el-option label="水电费" value="utility" />
            </el-select>
          </el-form-item>
          <el-button type="primary" @click="loadBills">查询</el-button>
        </el-form>
        <el-table :data="bills" v-loading="loading">
          <el-table-column prop="itemName" label="项目" />
          <el-table-column prop="period" label="账期" width="100" />
          <el-table-column prop="amount" label="应缴" width="90" />
          <el-table-column prop="paidAmount" label="已缴" width="90" />
          <el-table-column prop="status" label="状态" width="80">
            <template #default="{ row }">{{ { '0': '未缴', '1': '已缴', '2': '部分' }[row.status] }}</template>
          </el-table-column>
          <el-table-column prop="dueDate" label="截止日" width="110" />
        </el-table>
      </el-tab-pane>
      <el-tab-pane label="缴费记录" name="pay">
        <el-table :data="payments" v-loading="loading">
          <el-table-column prop="billId" label="账单ID" width="90" />
          <el-table-column prop="amount" label="金额" width="90" />
          <el-table-column prop="payChannel" label="渠道" width="90" />
          <el-table-column prop="tradeNo" label="交易号" />
          <el-table-column prop="payTime" label="缴费时间" width="170" />
        </el-table>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { listBillV2, listPayments } from '@/api/owner'

const tab = ref('bill')
const loading = ref(false)
const period = ref('')
const feeType = ref('')
const bills = ref([])
const payments = ref([])

async function loadBills() {
  loading.value = true
  try {
    const res = await listBillV2({ period: period.value || undefined, feeType: feeType.value || undefined })
    bills.value = res.data
  } finally { loading.value = false }
}

async function loadPayments() {
  payments.value = (await listPayments()).data
}

onMounted(() => {
  loadBills()
  loadPayments()
})
</script>

<style scoped>.mb-16{margin-bottom:16px}</style>
