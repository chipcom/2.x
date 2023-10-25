#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 25.10.23
function baseRate(dt, type_USL_OK)
  static aRate
  local ret := 1, row

  if isnil(aRate)
    // �� 2023 ��᫥ 01.10.2023 ������� �⠢�� ��樮��୮�� ���� 29995.8 ��
    // �� 2023 �� 01.10.2023 ������� �⠢�� ��樮��୮�� ���� 25986,7 ��
    // �� 2023 ������� �⠢�� ��� ���� �������� ��樮��� 15029,1 �� 
    // �� 2022 ������� �⠢�� ��樮��୮�� ���� 24322,6 ��
    // �� 2022 ������� �⠢�� ��� ���� �������� ��樮��� 13915,7 ��

    // ��� �᫮��� �������, ������� �⠢��, ��� ��砫�, ��� ����砭��
    aRate := { ;
      {USL_OK_HOSPITAL, 29995.8, 0d20231001, 0d20231231}, ; // �� 2023 � 01.10.23
      {USL_OK_HOSPITAL, 25986.7, 0d20230101, 0d20230930}, ; // �� 2023 �� 01.10.23
      {USL_OK_DAY_HOSPITAL, 15029.1, 0d20230101, 0d20231231}, ; // �� 2023
      {USL_OK_HOSPITAL, 24322.6, 0d20220101, 0d20221231}, ; // �� 2022
      {USL_OK_DAY_HOSPITAL, 13915.7, 0d20220101, 0d20221231} ; // �� 2022
    }
  endif
  for each row in aRate
    if row[1] == type_USL_OK .and. between_date(row[3], row[4], dt)
      ret := row[2]
    endif
  next
  return ret

// 13.03.23
function code_services_VMP(nYear)
  static arrVMP

  if isnil(arrVMP)
    arrVMP := hb_Hash()
    hb_HSet(arrVMP, 2023, '1.22.')
    hb_HSet(arrVMP, 2022, '1.21.')
    hb_HSet(arrVMP, 2021, '1.20.')
    hb_HSet(arrVMP, 2020, '1.12.')
    hb_HSet(arrVMP, 2019, '1.12.')
    hb_HSet(arrVMP, 2018, '1.12.')
  endif
  return iif(nYear < 2018, '', arrVMP[nYear])

// 13.03.23
function isServiceVMP(lshifr)
  local ret := .f.

  return ret