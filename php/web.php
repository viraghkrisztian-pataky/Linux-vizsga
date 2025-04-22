<!DOCTYPE html>
<html lang="hu">
<head>
  <meta charset="UTF-8">
  <title>PHP Vizsga – Kezdőlap</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="container text-center mt-5">
    <h1 class="display-4">Üdvözöllek a Linux Vizsgán!</h1>
    <p class="lead">Ez az oldal a gyakorlati vizsga egyik feladata.</p>

    <button id="startBtn" class="btn btn-success mt-4">Az oldal tesztelése!</button>

    <div class="mt-5 text-muted">
      <?php
        echo "Szerver idő: " . date("Y-m-d H:i:s");
      ?>
    </div>
  </div>

  <script src="script.js"></script>
</body>
</html>
