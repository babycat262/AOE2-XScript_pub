#include <iostream>
#include <string>
#include <math.h>
//#include <xs_functions.h>
using namespace std;

struct Date {
// 日期结构体
public:
    int Y = 0;    //年份
    int M = 1;    //月份
    int D = 1;    //天数
};


void xsSetTriggerVariable(int var, int val=-1) {}
/// //日历系统 ///
const int TV_year = 101;
const int TV_month = 102;
const int TV_day = 103;
const int TV_yday = 104;
// 根据year值确定是否闰年
int isLeap(int year=1000) {if((year%400 == 0) || (year%4 == 0)&&(year%100 != 0)){return (1);} return (0);}

int get_yday(int year, int month=1, int day=1) 
{// 根据月份和月内天数，计算这天是年内第几天
    int leap = isLeap(year);
    // 闰年标识缓存值
    static int leap_ = 0;  if(leap_ != leap) {leap_ = leap;}
    int yday = 0;
    switch(month) {
        case  1: {yday = day; break;}
        case  2: {yday = 31+day; break;}
        case  3: {yday = 31+(28+leap_)+day; break;}
        case  4: {yday = 31+(28+leap_)+31+day; break;}
        case  5: {yday = 31+(28+leap_)+31+30+day; break;}
        case  6: {yday = 31+(28+leap_)+31+30+31+day; break;}
        case  7: {yday = 31+(28+leap_)+31+30+31+30+day; break;}
        case  8: {yday = 31+(28+leap_)+31+30+31+30+31+day; break;}
        case  9: {yday = 31+(28+leap_)+31+30+31+30+31+31+day; break;}
        case 10: {yday = 31+(28+leap_)+31+30+31+30+31+31+30+day; break;}
        case 11: {yday = 31+(28+leap_)+31+30+31+30+31+31+30+31+day; break;}
        case 12: {yday = 31+(28+leap_)+31+30+31+30+31+31+30+31+30+day; break;}
        default: {return (-1);}
    }
    return (yday);
}

/**
 * @brief 世界公历：该函数按照一定间隔（触发器定时器，Rule间隔T）循环运行，每次运行对日期更新，在场景中模拟出日历更新效果。
 * ***** 参数说明 *****
 * @param TV_year, TV_month, TV_day, TV_yday : 常量ID。存储日历年月日的场景触发器变量编号
 * @param init_date: 函数首次执行时，使用该参数对日期进行初始化，init_date 是包含初始化year,month,day值的Vector
 * @param runs: 该日历函数的执行次数（全局累加）
 * @param year: 年份值（全局），取值范围：[0, +∞]
 * @param month: 月份值（全局），取值范围：[1, 12]
 * @param day: 月内天数（全局），取值范围：小月：[1,30]，大月：[1,31]，平（润）二月：[1, 28(29)]
 * @param yday: 一年内第几天（全局），取值范围：[1, 365(366)]
 * @fn <Int>isLeap: 该函数接收一个年份值，判断是否闰年。若为闰年返回1，否咋返回0
 * @return <Int> 返回该日历函数的累计执行次数
**/
void calendar_system(Date init_date)
{//日历系统
    static int runs = 0;    // 日历运行次数
    static int leap = 0;    // 闰年标识符
    // 日历初始日期
    static int year = init_date.Y;    // 初始年份
    static int month = init_date.M;    // 初始月份
    static int day = init_date.D;    // 初始 月内第day天
    static int yday = get_yday(year, month, day);    // 一年内第Y天
    //判断起始年份是否闰年？
    if(isLeap(year)==1 && runs==0) {leap = 1;}
    // 更新日期
    day++;  yday++;
    if(   yday==32       || yday== 60+leap || yday==91+leap 
       || yday==121+leap || yday==152+leap || yday==182+leap 
       || yday==213+leap || yday==244+leap || yday==274+leap 
       || yday==305+leap || yday==335+leap ) { month++;  day=1; }
    else if(yday > 365+leap)
    {
        year++;
        month=1;  day=1;  yday=1;
        leap = isLeap(year);    //判断下一年是否闰年
    }
    else {}
    // 同步触发器变量
    xsSetTriggerVariable(TV_year, year);
    xsSetTriggerVariable(TV_month, month);
    xsSetTriggerVariable(TV_day, day);
    xsSetTriggerVariable(TV_yday, yday);
    //solar_transform(1.0*month+0.01*day);    //将日期参数值传入季节系统
    runs++;
}

int main() {
    struct Date date = {907, 2, 4};
    //以date初始化日历
    //calendar_system(date);
}
