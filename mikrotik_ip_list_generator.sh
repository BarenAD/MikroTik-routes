#!/bin/bash

# Скрипт для генерации команд Mikrotik IP Firewall Address List
# 
# Использование: ./mikrotik_ip_list_generator.sh <input_file> <comment> [list_name] [output_file]
#
# Параметры:
#   input_file   - Путь к файлу с IP адресами (обязательный)
#   comment      - Комментарий для адрес-листа (обязательный)
#   list_name    - Название листа (опционально, по умолчанию: awg-list)
#   output_file  - Имя выходного файла (опционально, по умолчанию: mikrotik_ip_list_output.txt)

# Проверка обязательных параметров
if [ $# -lt 2 ]; then
    echo "Ошибка: Недостаточно параметров!"
    echo ""
    echo "Использование: $0 <input_file> <comment> [list_name] [output_file]"
    echo ""
    echo "Параметры:"
    echo "  input_file   - Путь к файлу с IP адресами (обязательный)"
    echo "  comment      - Комментарий для адрес-листа (обязательный)"
    echo "  list_name    - Название листа (опционально, по умолчанию: awg-list)"
    echo "  output_file  - Имя выходного файла (опционально, по умолчанию: mikrotik_ip_list_output.txt)"
    exit 1
fi

# Присвоение параметров
INPUT_FILE="$1"
COMMENT="$2"
LIST_NAME="${3:-awg-list}"
OUTPUT_FILE="${4:-mikrotik_ip_list_output.txt}"

# Проверка существования входного файла
if [ ! -f "$INPUT_FILE" ]; then
    echo "Ошибка: Файл '$INPUT_FILE' не найден!"
    exit 1
fi

# Проверка доступности для чтения
if [ ! -r "$INPUT_FILE" ]; then
    echo "Ошибка: Файл '$INPUT_FILE' недоступен для чтения!"
    exit 1
fi

# Очистка/создание выходного файла
> "$OUTPUT_FILE"

# Регулярное выражение для IP адреса (IPv4) с опциональной маской подсети
# Поддерживает: 1.2.3.4, 1.2.3.4/24, и т.д.
IP_REGEX='([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?'

# Чтение файла и обработка IP адресов
# Заменяем все разделители (пробелы, запятые, точки с запятой, переносы строк) на пробелы
# Затем извлекаем только IP адреса

# Читаем файл, заменяем все разделители на новые строки, фильтруем IP адреса
cat "$INPUT_FILE" | tr ',\t ;' '\n' | grep -oE "$IP_REGEX" | sort -u | while read -r ip; do
    echo "/ip firewall address-list add address=$ip list=$LIST_NAME comment=$COMMENT" >> "$OUTPUT_FILE"
done

# Подсчет количества обработанных IP
COUNT=$(wc -l < "$OUTPUT_FILE")

echo "Готово! Обработано IP адресов: $COUNT"
echo "Результат записан в файл: $OUTPUT_FILE"
