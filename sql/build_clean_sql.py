#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""从 Navicat 导出文件生成清理后的 smart_care_community.sql

用法：python build_clean_sql.py <navicat_export.sql>
"""

import re
import sys
from pathlib import Path
from typing import List

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "smart_care_community.sql"

SKIP_TABLES = {
    "cs_housekeeping",
    "cs_housekeeping_order",
    "cs_secondhand",
    "sys_user",
    "el_device",
    "el_health_record",
    "el_health_threshold",
    "el_disposal_plan",
}

CM_RESIDENT_DROP_COLS = {11, 22, 23, 24}

HEADER = """/*
 Smart Care Community - 完整数据库脚本（基于现网导出 2026-07-04 清理）
 用途：全新导入（会先 DROP 再 CREATE 全部表）
 数据库：smart_care_community
 说明：
   - 数据来源：Navicat 现网导出经 build_clean_sql.py 清理
   - 已移除废弃表：sys_user、el_device、el_health_*、el_disposal_plan、cs_housekeeping*、cs_secondhand
   - 已精简 cm_resident 废弃字段：family_members、is_primary_resident、is_alone_living、last_activity_time
   - 保留三端账号分表及全部在用的业务数据
 导入：mysql -uroot -p < sql/smart_care_community.sql
*/

CREATE DATABASE IF NOT EXISTS `smart_care_community` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `smart_care_community`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `cs_housekeeping_order`;
DROP TABLE IF EXISTS `cs_housekeeping`;
DROP TABLE IF EXISTS `cs_secondhand`;
DROP TABLE IF EXISTS `sys_user`;
DROP TABLE IF EXISTS `el_device`;
DROP TABLE IF EXISTS `sys_user_role`;
DROP TABLE IF EXISTS `sys_property_account`;
DROP TABLE IF EXISTS `sys_worker_account`;
DROP TABLE IF EXISTS `sys_owner_account`;
DROP TABLE IF EXISTS `pm_staff`;
DROP TABLE IF EXISTS `sys_role_menu`;
DROP TABLE IF EXISTS `sys_role`;
DROP TABLE IF EXISTS `sys_message_user`;
DROP TABLE IF EXISTS `sys_message`;
DROP TABLE IF EXISTS `sys_menu`;
DROP TABLE IF EXISTS `sys_login_log`;
DROP TABLE IF EXISTS `sys_config`;
DROP TABLE IF EXISTS `rp_worker_certificate`;
DROP TABLE IF EXISTS `rp_worker_skill`;
DROP TABLE IF EXISTS `rp_worker_profile`;
DROP TABLE IF EXISTS `rp_repair_weekly_report`;
DROP TABLE IF EXISTS `rp_repair_type`;
DROP TABLE IF EXISTS `rp_order_progress`;
DROP TABLE IF EXISTS `rp_order_field_image`;
DROP TABLE IF EXISTS `rp_order_field_record`;
DROP TABLE IF EXISTS `rp_order_image`;
DROP TABLE IF EXISTS `rp_order_eval`;
DROP TABLE IF EXISTS `rp_order`;
DROP TABLE IF EXISTS `cs_service_ticket`;
DROP TABLE IF EXISTS `ai_chat_message`;
DROP TABLE IF EXISTS `ai_chat_session`;
DROP TABLE IF EXISTS `kb_learn_draft`;
DROP TABLE IF EXISTS `kb_article`;
DROP TABLE IF EXISTS `el_utility_data`;
DROP TABLE IF EXISTS `el_temp_guardian`;
DROP TABLE IF EXISTS `el_ai_monitor_log`;
DROP TABLE IF EXISTS `el_health_threshold`;
DROP TABLE IF EXISTS `el_health_record`;
DROP TABLE IF EXISTS `el_disposal_plan`;
DROP TABLE IF EXISTS `el_care_staff_type`;
DROP TABLE IF EXISTS `el_care_staff`;
DROP TABLE IF EXISTS `el_disposal_record`;
DROP TABLE IF EXISTS `el_care_order`;
DROP TABLE IF EXISTS `el_alert`;
DROP TABLE IF EXISTS `cs_notice_read`;
DROP TABLE IF EXISTS `cs_notice`;
DROP TABLE IF EXISTS `cm_resident_tag_rel`;
DROP TABLE IF EXISTS `cm_resident_tag`;
DROP TABLE IF EXISTS `cm_resident`;
DROP TABLE IF EXISTS `cm_house`;
DROP TABLE IF EXISTS `cm_building`;

"""


def split_sql_values(inner: str) -> List[str]:
    values = []
    buf = []
    in_str = False
    depth = 0
    i = 0
    while i < len(inner):
        ch = inner[i]
        if in_str:
            buf.append(ch)
            if ch == "'":
                if i + 1 < len(inner) and inner[i + 1] == "'":
                    buf.append(inner[i + 1])
                    i += 2
                    continue
                in_str = False
            i += 1
            continue
        if ch == "'":
            in_str = True
            buf.append(ch)
        elif ch == "(":
            depth += 1
            buf.append(ch)
        elif ch == ")":
            depth -= 1
            buf.append(ch)
        elif ch == "," and depth == 0:
            values.append("".join(buf).strip())
            buf = []
        else:
            buf.append(ch)
        i += 1
    if buf:
        values.append("".join(buf).strip())
    return values


def patch_cm_resident_ddl_line(line: str) -> str:
    if any(k in line for k in (
        "`family_members`", "`is_primary_resident`",
        "`is_alone_living`", "`last_activity_time`",
    )):
        return None
    return line


def patch_cm_resident_insert(line: str) -> str:
    m = re.match(r"(INSERT INTO `cm_resident` VALUES\s*\()(.*)(\);?\s*)$", line.strip(), re.DOTALL)
    if not m:
        return line
    vals = split_sql_values(m.group(2))
    if len(vals) != 27:
        return line
    kept = [v for i, v in enumerate(vals) if i not in CM_RESIDENT_DROP_COLS]
    return m.group(1) + ", ".join(kept) + m.group(3)


def process(src_text: str) -> str:
    lines = src_text.splitlines()
    out = [HEADER.rstrip()]
    skip_block = False
    in_cm_resident_ddl = False

    for line in lines:
        # 跳过 Navicat 文件头
        if line.startswith("/*") or line.startswith(" Navicat") or line.startswith(" Source") \
                or line.startswith(" Target") or line.startswith(" File Encoding") or line.startswith(" Date:"):
            continue
        if line.strip() in ("*/",):
            continue
        if line.startswith("SET NAMES") or line.startswith("SET FOREIGN_KEY_CHECKS"):
            continue

        table_match = re.search(r"Table structure for (\w+)", line)
        if table_match:
            table = table_match.group(1)
            skip_block = table in SKIP_TABLES
            in_cm_resident_ddl = False
            if skip_block:
                continue
            out.append(line)
            continue

        if skip_block:
            continue

        if "CREATE TABLE `cm_resident`" in line:
            in_cm_resident_ddl = True
            out.append(line)
            continue

        if in_cm_resident_ddl:
            if line.strip().startswith(") ENGINE"):
                in_cm_resident_ddl = False
                out.append(line)
                continue
            patched = patch_cm_resident_ddl_line(line)
            if patched is not None:
                out.append(patched)
            continue

        if line.strip().startswith("INSERT INTO `cm_resident`"):
            out.append(patch_cm_resident_insert(line))
            continue

        out.append(line)

    text = "\n".join(out)
    if "SET FOREIGN_KEY_CHECKS = 1" not in text:
        text += "\n\nSET FOREIGN_KEY_CHECKS = 1;\n"
    return text if text.endswith("\n") else text + "\n"


def main():
    if len(sys.argv) < 2:
        print("用法: python build_clean_sql.py <navicat_export.sql>", file=sys.stderr)
        sys.exit(1)
    src = Path(sys.argv[1])
    if not src.is_file():
        print(f"源文件不存在: {src}", file=sys.stderr)
        sys.exit(1)
    text = src.read_text(encoding="utf-8")
    result = process(text)
    OUT.write_text(result, encoding="utf-8")
    skipped_found = [t for t in SKIP_TABLES if f"CREATE TABLE `{t}`" in result]
    print(f"Generated: {OUT} ({len(result)} bytes)")
    if skipped_found:
        print("WARNING still contains:", skipped_found)
    else:
        print("OK: all skip tables removed")
    if "`family_members`" in result:
        print("WARNING: cm_resident still has family_members column")
    else:
        print("OK: cm_resident columns trimmed")


if __name__ == "__main__":
    main()
