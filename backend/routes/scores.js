const express = require('express');
const { pool } = require('../db');
const auth = require('../middleware/auth');
const router = express.Router();

// Save a score (protected)
router.post('/', auth, async (req, res) => {
  const { game, score } = req.body;
  if (!game || score === undefined)
    return res.status(400).json({ error: 'game and score required' });

  try {
    const result = await pool.query(
      'INSERT INTO scores (user_id, game, score) VALUES ($1, $2, $3) RETURNING *',
      [req.user.id, game, score]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get leaderboard for a game
router.get('/leaderboard/:game', async (req, res) => {
  const { game } = req.params;
  try {
    const result = await pool.query(
      `SELECT u.username, MAX(s.score) as best_score, COUNT(*) as games_played
       FROM scores s
       JOIN users u ON s.user_id = u.id
       WHERE s.game = $1
       GROUP BY u.username
       ORDER BY best_score DESC
       LIMIT 10`,
      [game]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get my scores (protected)
router.get('/me', auth, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM scores WHERE user_id = $1 ORDER BY played_at DESC LIMIT 20',
      [req.user.id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
