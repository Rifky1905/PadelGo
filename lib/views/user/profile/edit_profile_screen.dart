import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/primary_button.dart';

/// Pengaturan akun — edit nama, email, dan nomor HP.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  String? _error;
  bool _saving = false;

  /// Foto profil yang baru dipilih (belum diupload sampai Simpan).
  Uint8List? _avatarBytes;
  String _avatarExt = 'jpg';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(text: user?.phone);
  }

  /// Pilih foto profil baru dari galeri — diupload saat Simpan.
  Future<void> _pickAvatar() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final ext = picked.name.split('.').last.toLowerCase();
    setState(() {
      _avatarBytes = bytes;
      _avatarExt =
          {'jpg', 'jpeg', 'png', 'webp'}.contains(ext) ? ext : 'jpg';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Nama tidak boleh kosong');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Format email tidak valid');
      return;
    }

    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();

    // Upload foto profil dulu kalau user memilih yang baru.
    if (_avatarBytes != null) {
      final ok = await auth.updateAvatar(_avatarBytes!, _avatarExt);
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _saving = false;
          _error = 'Gagal mengupload foto profil. Coba lagi.';
        });
        return;
      }
    }

    auth.updateProfile(name: name, email: email, phone: phone);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Akun')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar besar — tap untuk ganti foto profil
          Center(
            child: GestureDetector(
              onTap: _saving ? null : _pickAvatar,
              child: Stack(
                children: [
                  Builder(
                    builder: (_) {
                      final user = context.read<AuthProvider>().user;
                      return CircleAvatar(
                        radius: 46,
                        backgroundColor: PadelGoColors.primarySoft,
                        backgroundImage: _avatarBytes != null
                            ? MemoryImage(_avatarBytes!)
                            : (user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : null) as ImageProvider?,
                        child: (_avatarBytes == null &&
                                user?.avatarUrl == null)
                            ? Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text
                                        .trim()[0]
                                        .toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: PadelGoColors.primary,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: PadelGoColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_outlined,
                          color: Colors.white, size: 15),
                    ),
                  ),
                  if (_saving)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: PadelGoColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Tap foto untuk mengganti',
              style: TextStyle(
                fontSize: 11.5,
                color: PadelGoColors.textHint,
              ),
            ),
          ),
          const SizedBox(height: 18),

          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Nomor HP',
              hintText: '+62 ...',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PadelGoColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: PadelGoColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: PadelGoColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: _saving ? 'Menyimpan...' : 'Simpan Perubahan',
            icon: Icons.save_outlined,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
