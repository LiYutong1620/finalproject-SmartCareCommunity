package com.smartcare;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@MapperScan("com.smartcare.**.mapper")
@EnableScheduling
public class SmartCareApplication {

    public static void main(String[] args) {

        SpringApplication.run(SmartCareApplication.class, args);
        System.out.println("项目启动成功");
    }
}
