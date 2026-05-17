package com.smartcare.common.core.page;

import lombok.Data;

import java.util.List;

@Data
public class TableDataInfo {

    private long total;
    private List<?> rows;

    public TableDataInfo(long total, List<?> rows) {
        this.total = total;
        this.rows = rows;
    }
}
