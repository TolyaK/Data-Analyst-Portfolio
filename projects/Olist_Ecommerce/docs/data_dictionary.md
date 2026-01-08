# Data Dictionary

## 1. Orders Dataset (`olist_orders_dataset.csv`)
| **Имя поля** | **Описание** | **Тип данных** | **Допустимые значения** | **Примечания** |
| :--- | :--- | :--- | :--- | :--- |
| **order_id** | Уникальный идентификатор заказа | VARCHAR | Уникальный хэш | **PK** (Primary Key) |
| **customer_id** | Идентификатор сессии заказа | VARCHAR | Уникальный хэш | **FK** Ссылка на Customers. Важно: не является уникальным ID пользователя |
| **order_status** | Текущий статус заказа | VARCHAR | approved, canceled, delivered, invoiced, processing, shipped, unavailable | Для выручки используем только `delivered` |
| **order_purchase_timestamp** | Дата и время создания заказа | TIMESTAMP | YYYY-MM-DD HH:MM:SS | |
| **order_approved_at** | Дата и время подтверждения оплаты | TIMESTAMP | YYYY-MM-DD HH:MM:SS | |
| **order_delivered_carrier_date** | Дата передачи заказа в логистику | TIMESTAMP | YYYY-MM-DD HH:MM:SS | |
| **order_delivered_customer_date** | Дата вручения заказа клиенту | TIMESTAMP | YYYY-MM-DD HH:MM:SS | Факт доставки |
| **order_estimated_delivery_date** | Обещанная дата доставки | TIMESTAMP | YYYY-MM-DD HH:MM:SS | План доставки |

## 2. Customers Dataset (`olist_customers_dataset.csv`)
| **Имя поля** | **Описание** | **Тип данных** | **Допустимые значения** | **Примечания** |
| :--- | :--- | :--- | :--- | :--- |
| **customer_id** | Идентификатор сессии заказа | VARCHAR | Уникальный хэш | **PK** Ключ для связи с таблицей Orders |
| **customer_unique_id** | Уникальный идентификатор клиента | VARCHAR | Уникальный хэш | Реальный ID человека (User ID) |
| **customer_zip_code_prefix** | Почтовый индекс (префикс) | VARCHAR | 5 цифр | |
| **customer_city** | Город клиента | VARCHAR | Города Бразилии | |
| **customer_state** | Штат клиента | VARCHAR | 2 буквы (SP, RJ, etc.) | |

## 3. Order Items Dataset (`olist_order_items_dataset.csv`)
| **Имя поля** | **Описание** | **Тип данных** | **Допустимые значения** | **Примечания** |
| :--- | :--- | :--- | :--- | :--- |
| **order_id** | Уникальный идентификатор заказа | VARCHAR | Уникальный хэш | **FK** Ссылка на Orders |
| **order_item_id** | Порядковый номер товара в заказе | INT | 1, 2, 3... | Количество строк = количеству товаров в корзине |
| **product_id** | Уникальный идентификатор товара | VARCHAR | Уникальный хэш | **FK** Ссылка на Products |
| **seller_id** | Уникальный идентификатор продавца | VARCHAR | Уникальный хэш | **FK** Ссылка на Sellers |
| **shipping_limit_date** | Крайний срок отгрузки продавцом | TIMESTAMP | YYYY-MM-DD HH:MM:SS | |
| **price** | Цена товара | DECIMAL | Число > 0 | Без стоимости доставки |
| **freight_value** | Стоимость доставки | DECIMAL | Число >= 0 | |

## 4. Order Payments Dataset (`olist_order_payments_dataset.csv`)
| **Имя поля** | **Описание** | **Тип данных** | **Допустимые значения** | **Примечания** |
| :--- | :--- | :--- | :--- | :--- |
| **order_id** | Уникальный идентификатор заказа | VARCHAR | Уникальный хэш | **FK** Ссылка на Orders |
| **payment_sequential** | Номер платежа в последовательности | INT | 1, 2, 3... | Если клиент платил двумя картами |
| **payment_type** | Способ оплаты | VARCHAR | credit_card, boleto, voucher, debit_card | |
| **payment_installments** | Количество рассрочек | INT | 1 - 24 | |
| **payment_value** | Сумма транзакции | DECIMAL | Число > 0 | |

## 5. Order Reviews Dataset (`olist_order_reviews_dataset.csv`)
| **Имя поля** | **Описание** | **Тип данных** | **Допустимые значения** | **Примечания** |
| :--- | :--- | :--- | :--- | :--- |
| **review_id** | Уникальный ID отзыва | VARCHAR | Уникальный хэш | **PK??** |
| **order_id** | Уникальный идентификатор заказа | VARCHAR | Уникальный хэш | **FK** Ссылка на Orders |
| **review_score** | Оценка заказа | INT | 1 - 5 | Главный KPI качества |
| **review_comment_title** | Заголовок отзыва | TEXT | Текст | Часто NULL |
| **review_comment_message** | Текст отзыва | TEXT | Текст | Часто NULL |
| **review_creation_date** | Дата отправки опросника | TIMESTAMP | YYYY-MM-DD | |
| **review_answer_timestamp** | Дата ответа клиента | TIMESTAMP | YYYY-MM-DD HH:MM:SS | |

## 6. Products Dataset (`olist_products_dataset.csv`)
| **Имя поля** | **Описание** | **Тип данных** | **Допустимые значения** | **Примечания** |
| :--- | :--- | :--- | :--- | :--- |
| **product_id** | Уникальный ID товара | VARCHAR | Уникальный хэш | **PK** |
| **product_category_name** | Категория (на португальском) | VARCHAR | Text | Требует перевода (см. Translation table) |
| **product_name_lenght** | Длина названия | INT | | Метаданные (не критично) |
| **product_description_lenght**| Длина описания | INT | | Метаданные |
| **product_photos_qty** | Кол-во фото | INT | | Метаданные |
| **product_weight_g** | Вес (гр) | INT | | Логистика |
| **product_length_cm** | Длина (см) | INT | | Логистика |
| **product_height_cm** | Высота (см) | INT | | Логистика |
| **product_width_cm** | Ширина (см) | INT | | Логистика |

## 7. Sellers Dataset (`olist_sellers_dataset.csv`)
| **Имя поля** | **Описание** | **Тип данных** | **Допустимые значения** | **Примечания** |
| :--- | :--- | :--- | :--- | :--- |
| **seller_id** | Уникальный ID продавца | VARCHAR | Уникальный хэш | **PK** |
| **seller_zip_code_prefix** | Почтовый индекс продавца | VARCHAR | 5 цифр | |
| **seller_city** | Город продавца | VARCHAR | | |
| **seller_state** | Штат продавца | VARCHAR | 2 буквы | |

## 8. Geolocation (`olist_geolocation_dataset.csv`)
| **Имя поля** | **Описание** | **Тип данных** | **Допустимые значения** | **Примечания** |
| :--- | :--- | :--- | :--- | :--- |
| **geolocation_zip_code_prefix**| Префикс индекса | VARCHAR | 5 цифр | Связь с Customers/Sellers |
| **geolocation_lat** | Широта | DECIMAL | Координаты | |
| **geolocation_lng** | Долгота | DECIMAL | Координаты | |
| **geolocation_city** | Город | VARCHAR | | |
| **geolocation_state** | Штат | VARCHAR | | |

## 9. Category Translation (`product_category_name_translation.csv`)
| **Имя поля** | **Описание** | **Тип данных** | **Допустимые значения** | **Примечания** |
| :--- | :--- | :--- | :--- | :--- |
| **product_category_name** | Категория (PT) | VARCHAR | Португальский | **PK** |
| **product_category_name_english**| Категория (EN) | VARCHAR | Английский | Используем для дашборда |

