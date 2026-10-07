# UI/UX — Bengkel Paten (Tabler-inspired)

Prinsip: kartu bersih, hierarki jelas, kontrol padat tapi touch-friendly
(48dp aksi primer — sarung tangan/pencahayaan bengkel), badge status
konsisten, dialog konfirmasi destruktif, empty/skeleton/error+retry di
semua list, snackbar aman (tanpa stacktrace).

Komponen: AppColors/Typography/Spacing/Radius/Elevation/Icons,
AppButton/TextField/Dropdown/SearchField/Card/StatusBadge/Empty/Error/
Loading/ConfirmDialog/BottomSheet/Snackbar/Avatar/SectionHeader/StatCard/
FilterBar. Tema light penuh; dark architecture siap via ThemeMode.

Alur bengkel: timeline work-order (check-in→release) dari state server
aktual; foto-first inspeksi; aksi cepat task (START/PAUSE/FINISH) besar;
identifikasi customer/kendaraan jelas; navigasi dangkal.
Aksesibilitas: semantic label, kontras, text-scaling, target sentuh,
tidak hanya warna untuk status.
