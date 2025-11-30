-- 1. Sales per product (units + revenue)
SELECT
    p.produkt_id,
    p.nazwa AS produkt,
    k.nazwa AS kategoria,
    SUM(poz.ilosc) AS sprzedane_sztuki,
    SUM(poz.ilosc * p.cena) AS przychod
FROM pozycje_zamowien poz
JOIN produkty p ON poz.produkt_id = p.produkt_id
LEFT JOIN kategorie_produktow k ON p.kategoria_id = k.kategoria_id
GROUP BY p.produkt_id, p.nazwa, k.nazwa
ORDER BY przychod DESC;


-- 2. Sales by category
SELECT
    k.nazwa AS kategoria,
    COUNT(DISTINCT p.produkt_id) AS liczba_produktow,
    SUM(poz.ilosc) AS sprzedane_sztuki,
    SUM(poz.ilosc * p.cena) AS przychod_kategorii
FROM kategorie_produktow k
LEFT JOIN produkty p ON k.kategoria_id = p.kategoria_id
LEFT JOIN pozycje_zamowien poz ON p.produkt_id = poz.produkt_id
GROUP BY k.kategoria_id, k.nazwa
ORDER BY przychod_kategorii DESC;


-- 3. Top customers (total spend)
SELECT
    k.klient_id,
    k.imie,
    k.nazwisko,
    COUNT(DISTINCT z.zamowienie_id) AS liczba_zamowien,
    SUM(poz.ilosc * p.cena) AS laczna_kwota
FROM klienci k
LEFT JOIN zamowienia z         ON k.klient_id = z.klient_id
LEFT JOIN pozycje_zamowien poz ON z.zamowienie_id = poz.zamowienie_id
LEFT JOIN produkty p           ON poz.produkt_id = p.produkt_id
GROUP BY k.klient_id, k.imie, k.nazwisko
ORDER BY laczna_kwota DESC;


-- 4. Monthly revenue
SELECT
    DATE_FORMAT(z.data_zamowienia, '%Y-%m') AS miesiac,
    COUNT(DISTINCT z.zamowienie_id) AS liczba_zamowien,
    SUM(poz.ilosc * p.cena) AS przychod
FROM zamowienia z
JOIN pozycje_zamowien poz ON z.zamowienie_id = poz.zamowienie_id
JOIN produkty p           ON poz.produkt_id = p.produkt_id
GROUP BY miesiac
ORDER BY miesiac;


-- 5. Delivery performance by method
SELECT
    sposob_dostawy,
    COUNT(*) AS liczba_dostaw,
    COUNT(CASE WHEN status = 'delivered' THEN 1 END) AS dostarczone,
    ROUND(
        (COUNT(CASE WHEN status = 'delivered' THEN 1 END) / COUNT(*)) * 100,
        2
    ) AS procent_dostarczonych
FROM dostawy
GROUP BY sposob_dostawy;


-- 6. Payment method statistics
SELECT
    metoda,
    COUNT(*) AS liczba_transakcji,
    SUM(kwota) AS suma_transakcji
FROM platnosci
GROUP BY metoda
ORDER BY suma_transakcji DESC;


-- 7. Supplier sales
SELECT
    d.nazwa AS dostawca,
    p.nazwa AS produkt,
    SUM(poz.ilosc) AS sprzedane_sztuki,
    SUM(poz.ilosc * p.cena) AS przychod
FROM dostawcy d
JOIN dostawcy_produkty dp ON d.dostawca_id = dp.dostawca_id
JOIN produkty p           ON dp.produkt_id = p.produkt_id
LEFT JOIN pozycje_zamowien poz ON p.produkt_id = poz.produkt_id
GROUP BY d.nazwa, p.nazwa
ORDER BY dostawca, przychod DESC;


-- 8. Warehouse stock value
SELECT
    k.nazwa AS kategoria,
    SUM(p.stan_magazynowy) AS sztuki_na_magazynie,
    SUM(p.stan_magazynowy * p.cena) AS wartosc_magazynu
FROM produkty p
LEFT JOIN kategorie_produktow k ON p.kategoria_id = k.kategoria_id
GROUP BY k.kategoria_id, k.nazwa
ORDER BY wartosc_magazynu DESC;


-- 9. Order completion status (payment + delivery)
SELECT
    z.zamowienie_id,
    k.imie,
    k.nazwisko,
    p.status AS status_platnosci,
    d.status AS status_dostawy,
    CASE
        WHEN p.status = 'paid' AND d.status = 'delivered'
        THEN 'complete'
        ELSE 'incomplete'
    END AS status_zamowienia
FROM zamowienia z
LEFT JOIN klienci k   ON z.klient_id = k.klient_id
LEFT JOIN platnosci p ON z.zamowienie_id = p.zamowienie_id
LEFT JOIN dostawy d   ON z.zamowienie_id = d.zamowienie_id;