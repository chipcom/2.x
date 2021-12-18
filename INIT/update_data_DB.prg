******* 18.12.21 проведение изменений в содержимом БД при обновлении
function update_data_DB(aVersion)
  local snversion := int(aVersion[1]*10000 + aVersion[2]*100 + aVersion[3])
  local ver_base := get_version_DB()

  if ver_base < 21130 // переход на версию 2.11.30
    correct_DVN_COVID() // скоректироем листы углубленной диспансеризации
  endif

  return nil